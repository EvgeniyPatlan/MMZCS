#include <gtest/gtest.h>
#include <fstream>
#include <string>
#include <sstream>

// Function prototypes
void aes_encrypt(const std::string &input_file, const std::string &output_file, unsigned char *key);
void aes_decrypt(const std::string &input_file, const std::string &output_file, unsigned char *key);
void sha256(const std::string &password, unsigned char *hash);

// Test fixture class for common setup
class AESTest : public ::testing::Test {
protected:
    unsigned char key[32];   // AES-256 key length

    virtual void SetUp() {
        std::string password = "test_password";
        sha256(password, key);  // Derive key from password using SHA-256
    }
};

// Test if encryption and decryption produce the original data
TEST_F(AESTest, EncryptionDecryptionTest) {
    std::string input_file = "test_input.txt";
    std::string encrypted_file = "test_encrypted.bin";
    std::string decrypted_file = "test_decrypted.txt";

    // Create a test input file
    std::ofstream test_input(input_file);
    test_input << "This is a test for AES encryption and decryption.";
    test_input.close();

    // Encrypt the test input
    aes_encrypt(input_file, encrypted_file, key);

    // Decrypt the encrypted file
    aes_decrypt(encrypted_file, decrypted_file, key);

    // Read the decrypted content
    std::ifstream decrypted(decrypted_file);
    std::stringstream buffer;
    buffer << decrypted.rdbuf();
    std::string decrypted_content = buffer.str();

    // Verify that the decrypted content matches the original
    ASSERT_EQ(decrypted_content, "This is a test for AES encryption and decryption.");
}

// Main function for GoogleTest
int main(int argc, char **argv) {
    ::testing::InitGoogleTest(&argc, argv);
    return RUN_ALL_TESTS();
}
