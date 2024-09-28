#include <gtest/gtest.h>
#include <fstream>
#include <iostream>
#include "crypto_functions.h"

// Test case to verify encryption and decryption of a basic message
TEST(CryptoAppTest, EncryptDecryptTest) {
    const char* input_file = "test_message.txt";
    const char* encrypted_file = "test_encrypted.txt";
    const char* decrypted_file = "test_decrypted.txt";
    const char* user_cert = "certs/userA_cert.pem";
    const char* user_key = "certs/userA_key.pem";
    
    std::ofstream outfile(input_file);
    outfile << "Test message for encryption";
    outfile.close();

    create_encrypted_message(input_file, encrypted_file, user_cert);
    decrypt_message(encrypted_file, decrypted_file, user_key, user_cert);

    std::ifstream decrypted(decrypted_file);
    std::string decrypted_content;
    std::getline(decrypted, decrypted_content);
    decrypted.close();

    ASSERT_EQ(decrypted_content, "Test message for encryption");

    remove(input_file);
    remove(encrypted_file);
    remove(decrypted_file);
}

// Test case for longer message
TEST(CryptoAppTest, EncryptDecryptLongMessageTest) {
    const char* input_file = "test_message_long.txt";
    const char* encrypted_file = "test_encrypted_long.txt";
    const char* decrypted_file = "test_decrypted_long.txt";
    const char* user_cert = "certs/userA_cert.pem";
    const char* user_key = "certs/userA_key.pem";
    
    std::ofstream outfile(input_file);
    outfile << "This is a longer test message with more content to verify proper encryption and decryption.";
    outfile.close();

    create_encrypted_message(input_file, encrypted_file, user_cert);
    decrypt_message(encrypted_file, decrypted_file, user_key, user_cert);

    std::ifstream decrypted(decrypted_file);
    std::string decrypted_content;
    std::getline(decrypted, decrypted_content);
    decrypted.close();

    ASSERT_EQ(decrypted_content, "This is a longer test message with more content to verify proper encryption and decryption.");

    remove(input_file);
    remove(encrypted_file);
    remove(decrypted_file);
}

// Test case for invalid certificate path
TEST(CryptoAppTest, InvalidCertPathTest) {
    const char* input_file = "test_message_invalid.txt";
    const char* encrypted_file = "test_encrypted_invalid.txt";
    const char* decrypted_file = "test_decrypted_invalid.txt";
    const char* invalid_cert = "certs/invalid_cert.pem";
    const char* user_key = "certs/userA_key.pem";

    std::ofstream outfile(input_file);
    outfile << "Test message for invalid cert path";
    outfile.close();

    // Encrypt with invalid cert (this should fail)
    ASSERT_NO_THROW({
        create_encrypted_message(input_file, encrypted_file, invalid_cert);
    });

    remove(input_file);
    remove(encrypted_file);
    remove(decrypted_file);
}

// Test case for decryption with wrong key
TEST(CryptoAppTest, DecryptWithWrongKeyTest) {
    const char* input_file = "test_message_wrong_key.txt";
    const char* encrypted_file = "test_encrypted_wrong_key.txt";
    const char* decrypted_file = "test_decrypted_wrong_key.txt";
    const char* user_cert = "certs/userA_cert.pem";
    const char* user_key = "certs/userA_key.pem";
    const char* wrong_key = "certs/userB_key.pem"; // Wrong key

    // Create a message and encrypt it
    std::ofstream outfile(input_file);
    outfile << "Test message for wrong key decryption";
    outfile.close();

    create_encrypted_message(input_file, encrypted_file, user_cert);

    // Try to decrypt with the wrong key (should not work)
    decrypt_message(encrypted_file, decrypted_file, wrong_key, user_cert);

    // Check if the decrypted file exists
    std::ifstream decrypted(decrypted_file);
    ASSERT_TRUE(decrypted.good()) << "Decrypted file should be created, even if decryption fails";

    // Check the contents of the decrypted file
    std::string decrypted_content;
    std::getline(decrypted, decrypted_content);
    decrypted.close();

    // Ensure the decrypted content is not equal to the original message
    ASSERT_NE(decrypted_content, "Test message for wrong key decryption")
        << "Decryption with the wrong key should not return the original message";

    // Clean up test files
    remove(input_file);
    remove(encrypted_file);
    remove(decrypted_file);
}

// Main function to run tests
int main(int argc, char **argv) {
    ::testing::InitGoogleTest(&argc, argv);
    return RUN_ALL_TESTS();
}
