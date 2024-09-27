use strict;
use warnings;
use Getopt::Long;
use Log::Log4perl;
use Try::Tiny;
use IO::File;

# ГОСТ таблиця підстановки (S-Box)
my @SBOX = (
    [ 0x4, 0xA, 0x9, 0x2, 0xD, 0x8, 0x0, 0xE, 0x6, 0xB, 0x1, 0xC, 0x7, 0xF, 0x5, 0x3 ],
    [ 0xE, 0xB, 0x4, 0xC, 0x6, 0xD, 0xF, 0xA, 0x2, 0x3, 0x8, 0x0, 0x5, 0x9, 0x1, 0x7 ],
    [ 0x5, 0x8, 0x1, 0xD, 0xA, 0x3, 0x4, 0x2, 0xE, 0xF, 0xC, 0x7, 0x6, 0x0, 0x9, 0xB ],
    [ 0x7, 0xD, 0xA, 0x1, 0x0, 0x8, 0x9, 0xF, 0xE, 0x4, 0x6, 0xC, 0xB, 0x2, 0x5, 0x3 ],
    [ 0x6, 0xC, 0x7, 0x1, 0x5, 0xF, 0xD, 0x8, 0x4, 0xA, 0x9, 0xE, 0x0, 0x3, 0xB, 0x2 ],
    [ 0x4, 0xB, 0xA, 0x0, 0x7, 0x2, 0x1, 0xD, 0x3, 0x6, 0x8, 0x5, 0x9, 0xC, 0xF, 0xE ],
    [ 0xD, 0xB, 0x4, 0x1, 0x3, 0xF, 0x5, 0x9, 0x0, 0xA, 0xE, 0x7, 0x6, 0x8, 0x2, 0xC ],
    [ 0x1, 0xF, 0xD, 0x0, 0x5, 0x7, 0xA, 0x4, 0x9, 0x2, 0x3, 0xE, 0x6, 0xB, 0x8, 0xC ]
);

# Логування
Log::Log4perl->init(\<<'EOT');
log4perl.rootLogger              = DEBUG, LOGFILE, SCREEN

log4perl.appender.LOGFILE        = Log::Log4perl::Appender::File
log4perl.appender.LOGFILE.filename = gost_encryption.log
log4perl.appender.LOGFILE.layout = Log::Log4perl::Layout::PatternLayout
log4perl.appender.LOGFILE.layout.ConversionPattern = [%d] %p %m%n

log4perl.appender.SCREEN         = Log::Log4perl::Appender::Screen
log4perl.appender.SCREEN.stderr  = 1
log4perl.appender.SCREEN.layout  = Log::Log4perl::Layout::SimpleLayout
EOT

my $logger = Log::Log4perl->get_logger();

# Допоміжні функції для ГОСТ
sub rotate_left {
    my ($value, $bits) = @_;
    return (($value << $bits) & 0xFFFFFFFF) | ($value >> (32 - $bits));
}

sub gost_round {
    my ($half_block, $key) = @_;
    my $temp = ($half_block + $key) & 0xFFFFFFFF;
    my $result = 0;
    for my $i (0..7) {
        my $s_value = ($temp >> ($i * 4)) & 0xF;
        $result |= $SBOX[$i][$s_value] << ($i * 4);
    }
    return rotate_left($result, 11);
}

# ГОСТ-шифрування одного 64-бітного блоку
sub gost_encrypt_block {
    my ($block, $key) = @_;
    my ($n1, $n2) = unpack("N2", $block);
    for my $i (0..23) {
        my $round_key = $key->[$i % 8];
        my $temp = $n1;
        $n1 = $n2 ^ gost_round($n1, $round_key);
        $n2 = $temp;
    }
    for my $i (0..7) {
        my $round_key = $key->[7 - ($i % 8)];
        my $temp = $n1;
        $n1 = $n2 ^ gost_round($n1, $round_key);
        $n2 = $temp;
    }
    return pack("N2", $n2, $n1);
}

# ГОСТ-розшифрування одного 64-бітного блоку
sub gost_decrypt_block {
    my ($block, $key) = @_;
    my ($n1, $n2) = unpack("N2", $block);
    for my $i (0..7) {
        my $round_key = $key->[7 - ($i % 8)];
        my $temp = $n1;
        $n1 = $n2 ^ gost_round($n1, $round_key);
        $n2 = $temp;
    }
    for my $i (0..23) {
        my $round_key = $key->[$i % 8];
        my $temp = $n1;
        $n1 = $n2 ^ gost_round($n1, $round_key);
        $n2 = $temp;
    }
    return pack("N2", $n2, $n1);
}

# Padding (PKCS#7 padding)
sub pad_block {
    my ($block, $block_size) = @_;
    my $padding_len = $block_size - (length($block) % $block_size);
    return $block . chr($padding_len) x $padding_len;
}

# Remove padding
sub unpad_block {
    my ($block) = @_;
    my $padding_len = ord(substr($block, -1));
    return substr($block, 0, -$padding_len);
}

# ECB mode encryption
sub gost_ecb_encrypt {
    my ($data, $key) = @_;
    my $block_size = 8;
    my $padded_data = pad_block($data, $block_size);
    my $ciphertext = '';
    for (my $i = 0; $i < length($padded_data); $i += $block_size) {
        my $block = substr($padded_data, $i, $block_size);
        $ciphertext .= gost_encrypt_block($block, $key);
    }
    return $ciphertext;
}

# ECB mode decryption
sub gost_ecb_decrypt {
    my ($data, $key) = @_;
    my $block_size = 8;
    my $plaintext = '';
    for (my $i = 0; $i < length($data); $i += $block_size) {
        my $block = substr($data, $i, $block_size);
        $plaintext .= gost_decrypt_block($block, $key);
    }
    return unpad_block($plaintext);
}

# CTR mode encryption/decryption (symmetric)
sub gost_ctr {
    my ($data, $key, $iv) = @_;
    my $block_size = 8;
    my $ciphertext = '';
    my $counter = $iv;
    for (my $i = 0; $i < length($data); $i += $block_size) {
        my $block = substr($data, $i, $block_size);
        my $gamma = gost_encrypt_block($counter, $key);
        my $encrypted_block = $block ^ substr($gamma, 0, length($block));
        $ciphertext .= $encrypted_block;
        $counter = pack("N2", unpack("N2", $counter) + 1);  # Increment counter
    }
    return $ciphertext;
}

# CFB mode encryption
sub gost_cfb_encrypt {
    my ($data, $key, $iv) = @_;
    my $block_size = 8;
    my $ciphertext = '';
    my $previous_block = $iv;
    for (my $i = 0; $i < length($data); $i += $block_size) {
        my $block = substr($data, $i, $block_size);
        my $gamma = gost_encrypt_block($previous_block, $key);
        my $encrypted_block = $block ^ substr($gamma, 0, length($block));
        $ciphertext .= $encrypted_block;
        $previous_block = $encrypted_block;
    }
    return $ciphertext;
}

# CFB mode decryption
sub gost_cfb_decrypt {
    my ($data, $key, $iv) = @_;
    my $block_size = 8;
    my $plaintext = '';
    my $previous_block = $iv;
    for (my $i = 0; $i < length($data); $i += $block_size) {
        my $block = substr($data, $i, $block_size);
        my $gamma = gost_encrypt_block($previous_block, $key);
        my $decrypted_block = $block ^ substr($gamma, 0, length($block));
        $plaintext .= $decrypted_block;
        $previous_block = $block;
    }
    return $plaintext;
}

# Print help message
sub print_help {
    print <<'HELP';
Usage: gost_encrypt.pl [options]

Options:
  --input         Input file name (required)
  --output        Output file name (required)
  --key           Encryption key (32 hexadecimal characters) (required)
  --iv            Initialization vector (IV) (required for CTR and CFB modes)
  --mode          Operation mode: 1 for encryption, 2 for decryption (required)
  --cipher        Cipher mode: 
                      1 for ECB (Electronic Codebook),
                      2 for CTR (Counter),
                      3 for CFB (Cipher Feedback) (required)
  --help, -h      Show this help message

Example:
  perl gost_encrypt.pl --input input.txt --output output.enc --key 1234567890abcdef1234567890abcdef --iv abcdef1234567890 --mode 1 --cipher 2
HELP
    exit;
}

# Command line argument parsing
my $input_file;
my $output_file;
my $key;
my $iv;
my $mode;
my $cipher_mode;
my $help;

GetOptions(
    'input=s'   => \$input_file,
    'output=s'  => \$output_file,
    'key=s'     => \$key,
    'iv=s'      => \$iv,
    'mode=i'    => \$mode,
    'cipher=i'  => \$cipher_mode,
    'help|h'    => \$help,
) or die("Error in command line arguments\n");

# Show help if requested or required parameters are missing
if ($help) {
    print_help();
}

unless ($input_file && $output_file && $key && $mode && $cipher_mode) {
    print "Missing required arguments. Use --help for usage information.\n";
    exit;
}

# Validate key length
if (length($key) != 32) {
    die "Key must be 32 hexadecimal characters!";
}

# Read input file
my $input_data;
try {
    open my $fh, '<', $input_file or die "Cannot open input file: $!";
    local $/ = undef;
    $input_data = <$fh>;
    close $fh;
} catch {
    $logger->error("Failed to read input file: $_");
    die "Failed to read input file!";
};

# Encrypt or decrypt based on mode and cipher
my $output_data;
my @key_array = unpack("N8", pack("H*", $key));
try {
    if ($mode == 1) {
        if ($cipher_mode == 1) {
            $output_data = gost_ecb_encrypt($input_data, \@key_array);
        } elsif ($cipher_mode == 2) {
            $output_data = gost_ctr($input_data, \@key_array, $iv);
        } elsif ($cipher_mode == 3) {
            $output_data = gost_cfb_encrypt($input_data, \@key_array, $iv);
        }
    } elsif ($mode == 2) {
        if ($cipher_mode == 1) {
            $output_data = gost_ecb_decrypt($input_data, \@key_array);
        } elsif ($cipher_mode == 2) {
            $output_data = gost_ctr($input_data, \@key_array, $iv);
        } elsif ($cipher_mode == 3) {
            $output_data = gost_cfb_decrypt($input_data, \@key_array, $iv);
        }
    }
} catch {
    $logger->error("Encryption/Decryption failed: $_");
    die "Encryption/Decryption failed!";
};

# Write output file
try {
    open my $fh, '>', $output_file or die "Cannot open output file: $!";
    print $fh $output_data;
    close $fh;
    $logger->info("Operation completed successfully.");
} catch {
    $logger->error("Failed to write output file: $_");
    die "Failed to write output file!";
};
