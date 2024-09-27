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

# Custom LFSR function for key stream generation
sub lfsr {
    my ($init_value, $polynomial, $size, $key_length) = @_;
    my $state = $init_value;
    my @key_stream;

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
    return @key_stream;
}

# Function to read and return file content
sub read_file_block {
    my ($fh, $block_size) = @_;
    my $buffer;
    my $bytes_read = read($fh, $buffer, $block_size);
    return ($buffer, $bytes_read);
}

# Write a block of data to a file
sub write_file_block {
    my ($fh, $content) = @_;
    print $fh $content;
}

# XOR operation for encryption/decryption using LFSR key stream
sub xor_data {
    my ($data, @key_stream) = @_;
    my $key_index = 0;
    my $output_data = '';

    foreach my $byte (split //, $data) {
        my $byte_val = ord($byte);
        my $xor_byte = 0;

        for (my $i = 0; $i < 8; $i++) {
            $xor_byte |= (($byte_val >> $i) & 1) ^ $key_stream[$key_index++] << $i;
        }
        $output_data .= chr($xor_byte);
    }
    return $output_data;
}

# Encryption/Decryption function using LFSR
sub encrypt_decrypt_file {
    my ($input_file, $output_file, $polynomial, $init_value, $size, $operation) = @_;
    log_message("$operation operation started for file: $input_file");

    open my $in_fh, '<', $input_file or die "Failed to open input file $input_file: $!";
    binmode($in_fh);

    open my $out_fh, '>', $output_file or die "Failed to open output file $output_file: $!";
    binmode($out_fh);

    my $data = do { local $/; <$in_fh> };
    my $key_length = length($data) * 8;  # Length in bits

    my @key_stream = lfsr($init_value, $polynomial, $size, $key_length);
    my $output_data = xor_data($data, @key_stream);

    write_file_block($out_fh, $output_data);

    log_message("$operation operation completed for file: $input_file");
    close $in_fh;
    close $out_fh;
}

# Function to compare two files byte by byte
sub compare_files {
    my ($file1, $file2) = @_;
    log_message("Comparing files: $file1 and $file2");

    open my $fh1, '<', $file1 or die "Failed to open file $file1: $!";
    open my $fh2, '<', $file2 or die "Failed to open file $file2: $!";
    binmode($fh1);
    binmode($fh2);

    while (1) {
        my ($data1, $bytes1) = read_file_block($fh1, 1024);
        my ($data2, $bytes2) = read_file_block($fh2, 1024);

        last if !$bytes1 && !$bytes2;
        if ($bytes1 != $bytes2 || $data1 ne $data2) {
            log_message("Files do not match: $file1 and $file2");
            return 0;
        }
    }

    log_message("Files match: $file1 and $file2");
    close $fh1;
    close $fh2;
    return 1;
}

# Function to validate polynomial and initial value
sub validate_inputs {
    my ($polynomial, $init_value, $size) = @_;
    log_message("Validating inputs: Polynomial = $polynomial, Init value = $init_value, Size = $size");

    die "Invalid polynomial! Must be between 1 and 2^$size-1.\n"
        if ($polynomial < 1 || $polynomial >= (1 << $size));

    die "Invalid initial value! Must be between 1 and 2^$size-1.\n"
        if ($init_value < 1 || $init_value >= (1 << $size));

    log_message("Input validation passed.");
}

# Command-line options
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

die "Input file, encrypted file, decrypted file, polynomial, and init_value are required."
    unless $input_file && $encrypted_file && $decrypted_file && $polynomial && $init_value;

die "Invalid size! Must be between 1 and 64.\n" unless $size >= 1 && $size <= 64;

validate_inputs($polynomial, $init_value, $size);

# Encrypt and decrypt files
encrypt_decrypt_file($input_file, $encrypted_file, $polynomial, $init_value, $size, "Encryption");
print "File has been encrypted. Output saved to $encrypted_file\n";

encrypt_decrypt_file($encrypted_file, $decrypted_file, $polynomial, $init_value, $size, "Decryption");
print "File has been decrypted. Output saved to $decrypted_file\n";

# Compare decrypted file with the original
if (compare_files($input_file, $decrypted_file)) {
    print "Decrypted file matches the original file. Encryption is correct.\n";
} else {
    print "Decrypted file does not match the original file. Check the algorithm.\n";
}

close $log_fh;
