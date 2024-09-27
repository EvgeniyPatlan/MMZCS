#!/usr/bin/perl
use strict;
use warnings;
use bigint;
use Getopt::Long;
use Time::Piece;

# Log file for logging
open my $log_fh, '>', 'encryption.log' or die "Failed to open log file: $!";

sub log_message {
    my ($message) = @_;
    my $timestamp = localtime->strftime('%Y-%m-%d %H:%M:%S');
    print $log_fh "[$timestamp] $message\n";
}

# LFSR function for generating the key stream
sub lfsr {
    my ($init_value, $polynomial, $size, $key_length) = @_;
    my $state = $init_value;
    my @key_stream;

    log_message("Initial LFSR state: $state, Polynomial: $polynomial, Size: $size, Key Length: $key_length");
    
    for (1 .. $key_length) {
        my $feedback = $state & 1;
        my $xor_val = 0;
        
        my $poly = $polynomial;
        for (my $i = 0; $i < $size; $i++) {
            $xor_val ^= ($state >> $i) & ($poly & 1);
            $poly >>= 1;
        }

        $state = ($state >> 1) | ($xor_val << ($size - 1));

        push @key_stream, $feedback;
    }

    log_message("Generated key stream: @key_stream");
    return @key_stream;
}

# Function to read a file and return its content
sub read_file {
    my ($filename) = @_;
    open my $fh, '<', $filename or die "Failed to open input file $filename: $!";
    binmode($fh);
    my $content = do { local $/; <$fh> };
    close $fh;
    return $content;
}

# Function to write binary content to a file
sub write_file {
    my ($filename, $content) = @_;
    open my $fh, '>', $filename or die "Failed to create output file $filename: $!";
    binmode($fh);
    print $fh $content;
    close $fh;
}

# Function to XOR the data with the generated key stream and log details
sub xor_data {
    my ($data, @key_stream) = @_;
    my $key_index = 0;
    my $output_data = '';

    foreach my $byte (split //, $data) {
        my $byte_val = ord($byte);
        my $xor_byte = 0;

        for (my $i = 0; $i < 8; $i++) {
            my $bit = ($byte_val >> $i) & 1;
            my $key_bit = $key_stream[$key_index++];
            my $result_bit = $bit ^ $key_bit;
            $xor_byte |= $result_bit << $i;

            log_message("Byte: $byte_val, Bit: $bit, Key bit: $key_bit, XOR result: $result_bit");
        }

        log_message("Original byte: $byte_val, XOR byte: $xor_byte");
        $output_data .= chr($xor_byte);
    }

    return $output_data;
}


# Function to XOR the data with the generated key stream
sub xor_data1 {
    my ($data, @key_stream) = @_;
    my $key_index = 0;
    my $output_data = '';

    foreach my $byte (split //, $data) {
        my $byte_val = ord($byte);
        my $xor_byte = 0;

        for (my $i = 0; $i < 8; $i++) {
            $xor_byte |= (($byte_val >> $i) & 1) ^ $key_stream[$key_index++] << $i;
        }

        log_message("Original byte: $byte_val, XOR byte: $xor_byte");
        $output_data .= chr($xor_byte);
    }

    return $output_data;
}

# Encryption/Decryption function using LFSR
sub encrypt_decrypt_file {
    my ($input_file, $output_file, $polynomial, $init_value, $size, $operation) = @_;
    log_message("$operation operation started for file: $input_file");

    my $data = read_file($input_file);
    my $key_length = length($data) * 8;

    log_message("Key length (in bits): $key_length");

    my @key_stream = lfsr($init_value, $polynomial, $size, $key_length);
    my $output_data = xor_data($data, @key_stream);

    write_file($output_file, $output_data);
    log_message("$operation operation completed for file: $input_file");
}

# Function to compare two files byte by byte and log the differences
sub compare_files {
    my ($file1, $file2) = @_;
    log_message("Comparing files: $file1 and $file2");

    open my $fh1, '<', $file1 or die "Failed to open file $file1: $!";
    open my $fh2, '<', $file2 or die "Failed to open file $file2: $!";
    binmode($fh1);
    binmode($fh2);

    my $pos = 0;
    while (1) {
        my $byte1;
        my $byte2;
        my $bytes1 = read($fh1, $byte1, 1);
        my $bytes2 = read($fh2, $byte2, 1);

        last if !$bytes1 && !$bytes2;

        if ($byte1 ne $byte2) {
            log_message("Difference at position $pos: File1 = " . ord($byte1) . ", File2 = " . ord($byte2));
            return 0;
        }
        $pos++;
    }

    log_message("Files match: $file1 and $file2");
    close $fh1;
    close $fh2;
    return 1;
}

# Command-line options and help message
sub print_help {
    print <<'END_HELP';
Usage: perl lab1.pl [options]

Options:
  --input=s        Input file to be encrypted/decrypted.
  --encrypted=s    File to save the encrypted output.
  --decrypted=s    File to save the decrypted output.
  --polynomial=i   Polynomial for LFSR (as a decimal integer).
  --init_value=i   Initial value for LFSR (as a decimal integer).
  --size=i         Size of the LFSR in bits (1-64).
  --help           Show this help message.

Example:
  perl lab1.pl --input=input.txt --encrypted=enc.txt --decrypted=dec.txt --polynomial=285 --init_value=12345 --size=32
END_HELP
    exit;
}

# Parse command-line options
my $input_file;
my $encrypted_file;
my $decrypted_file;
my $polynomial;
my $init_value;
my $size = 64;  # Default LFSR size
my $help;

GetOptions(
    "input=s"       => \$input_file,
    "encrypted=s"   => \$encrypted_file,
    "decrypted=s"   => \$decrypted_file,
    "polynomial=i"  => \$polynomial,
    "init_value=i"  => \$init_value,
    "size=i"        => \$size,
    "help"          => \$help
) or die "Error in command-line arguments\n";

if ($help) {
    print_help();
}

# Ensure required parameters are provided
die "Input file, encrypted file, decrypted file, polynomial, and init_value are required. Use --help for more information.\n"
    unless $input_file && $encrypted_file && $decrypted_file && $polynomial && $init_value;

# Ensure size is between 1 and 64 bits
die "Invalid size! Must be between 1 and 64.\n" unless $size >= 1 && $size <= 64;

# Encrypt the file
encrypt_decrypt_file($input_file, $encrypted_file, $polynomial, $init_value, $size, "Encryption");
print "File has been encrypted. Output saved to $encrypted_file\n";

# Decrypt the file
encrypt_decrypt_file($encrypted_file, $decrypted_file, $polynomial, $init_value, $size, "Decryption");
print "File has been decrypted. Output saved to $decrypted_file\n";

# Compare the original and decrypted files
if (compare_files($input_file, $decrypted_file)) {
    print "Decrypted file matches the original file. Encryption is correct.\n";
} else {
    print "Decrypted file does not match the original file. Check the algorithm.\n";
}

# Close the log file
close $log_fh;

