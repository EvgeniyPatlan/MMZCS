#include <iostream>
#include <string>

// Function prototypes for the crypto functions
void aes_encrypt(const std::string &input_file, const std::string &output_file, unsigned char *key);
void aes_decrypt(const std::string &input_file, const std::string &output_file, unsigned char *key);
void sha256(const std::string &password, unsigned char *hash);

int main() {
    std::string password;
    std::string input_file;
    std::string output_file;
    std::string operation;
    unsigned char key[32]; // AES-256 key length

    std::cout << "Enter password: ";
    std::cin >> password;

    sha256(password, key); // Derive AES-256 key from SHA-256 hashed password

    std::cout << "Enter operation (encrypt/decrypt): ";
    std::cin >> operation;

    std::cout << "Enter input file path: ";
    std::cin >> input_file;

    std::cout << "Enter output file path: ";
    std::cin >> output_file;

    if (operation == "encrypt") {
        aes_encrypt(input_file, output_file, key);
        std::cout << "File encrypted successfully.\n";
    } else if (operation == "decrypt") {
        aes_decrypt(input_file, output_file, key);
        std::cout << "File decrypted successfully.\n";
    } else {
        std::cerr << "Invalid operation.\n";
        return 1;
    }

    return 0;
}
