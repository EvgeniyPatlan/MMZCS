#!/usr/bin/perl

use strict;
use warnings;
use GOST_Encryption;

# Request parameters from the user
print "Enter the input file name: ";
my $input_file = <STDIN>;
chomp($input_file);

print "Enter the output file name: ";
my $output_file = <STDIN>;
chomp($output_file);

print "Enter the key (64-byte in hexadecimal format): ";
my $key_input = <STDIN>;
chomp($key_input);
my $key = pack("H*", $key_input);

print "Enter the initialization vector (IV) (16-byte in hexadecimal format): ";
my $iv_input = <STDIN>;
chomp($iv_input);
my $iv = pack("H*", $iv_input);

print "Choose operation mode (encrypt/decrypt): ";
my $operation = <STDIN>;
chomp($operation);

print "Choose encryption mode (ECB/OFB/CFB): ";
my $mode = <STDIN>;
chomp($mode);

# Reading data from the file
open(my $in, '<', $input_file) or die "Failed to open the input file: $!";
binmode($in);
my $data = do { local $/; <$in> };
close($in);

# Generate round keys
my $keys = GOST_Encryption::generate_keys($key);

# Select encryption mode
my $result;
if ($mode eq 'ECB') {
    $result = GOST_Encryption::ecb_mode($data, $keys, $operation);
}
elsif ($mode eq 'OFB') {
    $result = GOST_Encryption::ofb_mode($data, $keys, $iv, $operation);
}
elsif ($mode eq 'CFB') {
    $result = GOST_Encryption::cfb_mode($data, $keys, $iv, $operation);
} else {
    die "Invalid encryption mode.";
}

# Write the result to the output file
open(my $out, '>', $output_file) or die "Failed to open the output file: $!";
binmode($out);
print $out $result;
close($out);

print "Operation completed successfully!\n";

