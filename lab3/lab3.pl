#!/usr/bin/perl
use strict;
use warnings;
use feature 'say';

# Lehmer random number generator (modulus should be 2^32)
sub lehmer_rng {
    my ($seed, $modulus, $multiplier) = @_;
    return ($seed * $multiplier) % $modulus;
}

# RXOR Hash function (custom XOR-based hash)
sub rxor_hash {
    my ($vector) = @_;
    my $hash = 0;
    foreach my $char (split //, $vector) {
        $hash ^= ord($char);
    }
    return $hash;
}

# Read master key from user input with validation (only binary input allowed)
sub get_master_key {
    print "Enter the master key (in binary, e.g., 10101100): ";
    chomp(my $master_key = <STDIN>);
    
    # Validate the input: check that it is only binary (0 or 1)
    unless ($master_key =~ /^[01]+$/) {
        die "Invalid master key. Please enter a binary string (e.g., 10101100).\n";
    }
    
    return $master_key;
}

# XOR encryption function
sub xor_encrypt {
    my ($data, $key) = @_;
    my $encrypted = '';
    for (my $i = 0; $i < length($data); $i++) {
        $encrypted .= chr(ord(substr($data, $i, 1)) ^ ord(substr($key, $i % length($key), 1)));
    }
    return $encrypted;
}

# Main process
my $N = 16;  # Example key length (adjust as needed)
my $session_file = "s_key.txt";
my $master_key_file = "m_key.txt";

# Step 1: Generate session key using Lehmer algorithm
my $session_key_seed = 12345;  # Example seed value
my $session_key_modulus = 2 ** (2 * $N);  # Modulus based on block size 2w
my $session_key_multiplier = 48271;  # Example multiplier
my $session_key = lehmer_rng($session_key_seed, $session_key_modulus, $session_key_multiplier);

# Save session key to file
open(my $sk_fh, '>', $session_file) or die "Could not open '$session_file' for writing: $!";
print $sk_fh $session_key;
close($sk_fh);
say "Session key generated and saved to '$session_file'.";

# Step 2: Generate control vector using Lehmer algorithm
my $control_vector_seed = 54321;  # Example seed for control vector
my $control_vector_modulus = 2 ** (5 * $N);  # Modulus based on control vector size 5N
my $control_vector = lehmer_rng($control_vector_seed, $control_vector_modulus, $session_key_multiplier);
say "Control vector generated.";

# Step 3: Apply RXOR hash to control vector
my $hashed_vector = rxor_hash($control_vector);
say "Control vector hashed using RXOR.";

# Step 4: Get master key from user
my $master_key = get_master_key();

# Step 5: XOR master key with RXOR hashed control vector
my $encryption_key = $master_key ^ $hashed_vector;

# Step 6: Encrypt session key
open(my $sk_in, '<', $session_file) or die "Could not open '$session_file' for reading: $!";
chomp(my $session_key_plain = <$sk_in>);
close($sk_in);

my $encrypted_session_key = xor_encrypt($session_key_plain, $encryption_key);

# Step 7: Save encrypted session key to "m_key.txt"
open(my $mk_fh, '>', $master_key_file) or die "Could not open '$master_key_file' for writing: $!";
print $mk_fh $encrypted_session_key;
close($mk_fh);
say "Encrypted session key saved to '$master_key_file'.";

# Step 8: Display results
say "Encryption completed successfully.";
say "Session Key: $session_key";
say "Encrypted Session Key: $encrypted_session_key";

