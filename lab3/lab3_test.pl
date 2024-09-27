#!/usr/bin/perl
use strict;
use warnings;
use Test::More tests => 6;
require './lab3.pl';  # Include the main script

# Test 1: Lehmer RNG session key generation
subtest 'Test Lehmer RNG' => sub {
    my $seed = 12345;
    my $modulus = 2 ** 32;
    my $multiplier = 48271;
    
    my $session_key = lehmer_rng($seed, $modulus, $multiplier);
    ok($session_key > 0, 'Session key is generated');
    is($session_key, 595905495, 'Session key matches expected value');
};

# Test 2: RXOR hash function
subtest 'Test RXOR Hash' => sub {
    my $vector = 'testvector';
    my $hash = rxor_hash($vector);
    is($hash, 15, 'RXOR hash matches expected value');
};

# Test 3: XOR encryption and decryption
subtest 'Test XOR Encryption and Decryption' => sub {
    my $data = 'plaintext';
    my $key = 'keykeyke';
    
    my $encrypted = xor_encrypt_decrypt($data, $key);
    isnt($encrypted, $data, 'Data is encrypted');
    
    my $decrypted = xor_encrypt_decrypt($encrypted, $key);
    is($decrypted, $data, 'Data is correctly decrypted');
};

# Test 4: Integration test (encryption-decryption)
subtest 'Integration test: Encryption and Decryption' => sub {
    # Generate session key
    my $session_key_seed = 12345;
    my $session_key_modulus = 2 ** 32;
    my $session_key_multiplier = 48271;
    my $session_key = lehmer_rng($session_key_seed, $session_key_modulus, $session_key_multiplier);

    # Generate control vector
    my $control_vector_seed = 54321;
    my $control_vector_modulus = 2 ** (5 * 16);
    my $control_vector = lehmer_rng($control_vector_seed, $control_vector_modulus, $session_key_multiplier);

    # Hash control vector using RXOR
    my $hashed_vector = rxor_hash($control_vector);

    # Use a sample master key
    my $master_key = '10101010';
    
    # Create encryption key
    my $encryption_key = $master_key ^ $hashed_vector;

    # Encrypt session key
    my $encrypted_session_key = xor_encrypt_decrypt($session_key, $encryption_key);

    # Decrypt session key
    my $decrypted_session_key = xor_encrypt_decrypt($encrypted_session_key, $encryption_key);

    # Check if the decrypted key matches the original session key
    is($decrypted_session_key, $session_key, 'Session key was successfully decrypted and matches the original');
};

# Test 5: File handling for session key
subtest 'Test file handling' => sub {
    my $session_file = 's_key.txt';
    open(my $fh, '>', $session_file) or die "Cannot open $session_file: $!";
    print $fh 'Test session key';
    close($fh);
    
    ok(-e $session_file, 'Session key file created');
};

# Test 6: File handling for encrypted session key
subtest 'Test encrypted session key file handling' => sub {
    my $master_key_file = 'm_key.txt';
    open(my $fh, '>', $master_key_file) or die "Cannot open $master_key_file: $!";
    print $fh 'Test encrypted key';
    close($fh);
    
    ok(-e $master_key_file, 'Encrypted session key file created');
};

