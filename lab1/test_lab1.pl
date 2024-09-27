#!/usr/bin/perl
use strict;
use warnings;
use File::Compare;
use File::Copy;
use File::Temp qw(tempfile);
use File::Path qw(make_path);
use Time::Piece;

# Path to the encryption script
my $encryption_script = "lab1.pl";  # Ensure this points to the correct script

# Temporary directory for test files
my $test_dir = "test_files";  # Relative path for storing test files

# Log file for logging
open my $log_fh, '>', 'test_log.log' or die "Failed to open log file: $!";
sub log_message {
    my ($message) = @_;
    my $timestamp = localtime->strftime('%Y-%m-%d %H:%M:%S');
    print $log_fh "[$timestamp] $message\n";
}

# Function to create test directory if it doesn't exist
sub create_test_dir {
    unless (-d $test_dir) {
        make_path($test_dir) or die "Failed to create test directory $test_dir: $!";
        print "Created test directory: $test_dir\n";
    }
}

# Function to replace spaces with underscores
sub sanitize_filename {
    my ($filename) = @_;
    $filename =~ s/\s+/_/g;  # Replace spaces with underscores
    return $filename;
}

# Function to create a test file
sub create_test_file {
    my ($filename, $content) = @_;
    
    # Ensure directory exists
    create_test_dir();
    
    # Create the test file
    open my $fh, '>', "$filename" or die "Failed to create test file $filename: $!";
    print $fh $content;
    close $fh;
    log_message("Created test file $filename");
}

# Function to run the encryption script
sub run_encryption_script {
    my ($input, $encrypted, $decrypted, $polynomial, $init_value, $size) = @_;
    
    # Run the encryption script with sanitized filenames
    my $command = "perl $encryption_script --input $input --encrypted $encrypted --decrypted $decrypted --polynomial $polynomial --init_value $init_value --size $size";
    print "Running: $command\n";
    log_message("Running: $command");
    system($command) == 0 or die "Encryption script failed: $!";
}

# Function to compare files and return result
sub compare_files {
    my ($file1, $file2) = @_;
    if (compare($file1, $file2) == 0) {
        log_message("Files $file1 and $file2 match.");
        return 1;
    } else {
        log_message("Files $file1 and $file2 do not match.");
        return 0;
    }
}

# Function to run the test case
sub run_test {
    my ($test_name, $content, $polynomial, $init_value, $size) = @_;

    print "Running test: $test_name\n";
    log_message("Running test: $test_name");

    # Sanitize filenames by replacing spaces with underscores
    my $sanitized_test_name = sanitize_filename($test_name);

    my $input_file = "$test_dir/input_$sanitized_test_name.txt";
    my $encrypted_file = "$test_dir/encrypted_$sanitized_test_name.enc";
    my $decrypted_file = "$test_dir/decrypted_$sanitized_test_name.txt";

    # Create test input file
    create_test_file($input_file, $content);

    # Run encryption and decryption
    run_encryption_script($input_file, $encrypted_file, $decrypted_file, $polynomial, $init_value, $size);

    # Check if the decrypted file matches the original file
    if (compare_files($input_file, $decrypted_file)) {
        print "Test '$test_name' passed.\n";
        log_message("Test '$test_name' passed.");
    } else {
        print "Test '$test_name' failed. Decrypted file does not match original.\n";
        log_message("Test '$test_name' failed. Decrypted file does not match original.");
    }
}

# Clean up test files
sub cleanup {
    unlink glob "$test_dir/*";
    log_message("Cleaned up test files.");
}

# Main function to run all tests
sub main {
    # Clean up old test files
    cleanup();

    # Define test cases
    my @test_cases = (
        {
            name       => 'Simple Text',
            content    => 'Hello, World!',
            polynomial => 285,  # Example polynomial
            init_value => 12345,
            size       => 32
        },
        {
            name       => 'Repeating Pattern',
            content    => 'ABCD' x 100,
            polynomial => 29,
            init_value => 54321,
            size       => 64
        },
        {
            name       => 'Binary Data',
            content    => pack("H*", 'deadbeefcafe'),
            polynomial => 511,
            init_value => 13579,
            size       => 16
        }
    );

    # Run each test case
    foreach my $test_case (@test_cases) {
        run_test(
            $test_case->{name},
            $test_case->{content},
            $test_case->{polynomial},
            $test_case->{init_value},
            $test_case->{size}
        );
    }

    # Clean up test files
    cleanup();
}

# Execute the tests
main();

# Close the log file
close $log_fh;

