include <openssl/evp.h>
#include <openssl/err.h>
#include <openssl/rand.h>
#include <iostream>
#include <fstream>
#include <string>
#include <vector>
#include <cstring>

void handleErrors() {
    ERR_print_errors_fp(stderr);
    abort();
}

// Use the EVP API for SHA-256 hashing
void sha256(const std::string &password, unsigned char *hash) {
    EVP_MD_CTX *mdctx = EVP_MD_CTX_new();
    if (mdctx == NULL) handleErrors();

    if (1 != EVP_DigestInit_ex(mdctx, EVP_sha256(), NULL)) handleErrors();
    if (1 != EVP_DigestUpdate(mdctx, password.c_str(), password.size())) handleErrors();
    if (1 != EVP_DigestFinal_ex(mdctx, hash, NULL)) handleErrors();

    EVP_MD_CTX_free(mdctx);
}

void print_hex(const std::string &label, unsigned char *data, int length) {
    std::cout << label << ": ";
    for (int i = 0; i < length; i++) {
        std::cout << std::hex << (int)data[i];
    }
    std::cout << std::dec << "\n";
}

// Encrypt the file with AES-256 CBC, generating a random IV and prepending it to the output file
void aes_encrypt(const std::string &input_file, const std::string &output_file, unsigned char *key) {
    unsigned char iv[16]; // AES block size is 16 bytes
    if (!RAND_bytes(iv, sizeof(iv))) {
        handleErrors();
    }

    EVP_CIPHER_CTX *ctx = EVP_CIPHER_CTX_new();
    if (!ctx) handleErrors();

    if (1 != EVP_EncryptInit_ex(ctx, EVP_aes_256_cbc(), NULL, key, iv)) handleErrors();

    std::ifstream ifs(input_file, std::ios::binary);
    std::ofstream ofs(output_file, std::ios::binary);

    if (!ifs.is_open() || !ofs.is_open()) {
        std::cerr << "Error opening file.\n";
        return;
    }

    // Write the IV to the output file first
    ofs.write(reinterpret_cast<const char*>(iv), sizeof(iv));

    const size_t buffer_size = 1024;
    std::vector<unsigned char> buffer(buffer_size);
    std::vector<unsigned char> ciphertext(buffer_size + EVP_CIPHER_block_size(EVP_aes_256_cbc()));

    int len;
    int ciphertext_len = 0;

    while (ifs.read(reinterpret_cast<char*>(buffer.data()), buffer_size) || ifs.gcount()) {
        if (1 != EVP_EncryptUpdate(ctx, ciphertext.data(), &len, buffer.data(), ifs.gcount())) handleErrors();
        ofs.write(reinterpret_cast<char*>(ciphertext.data()), len);
        ciphertext_len += len;
    }

    if (1 != EVP_EncryptFinal_ex(ctx, ciphertext.data(), &len)) handleErrors();
    ofs.write(reinterpret_cast<char*>(ciphertext.data()), len);
    ciphertext_len += len;

    EVP_CIPHER_CTX_free(ctx);

    // Print key and IV for debugging
    print_hex("Encryption key", key, 32);
    print_hex("Encryption IV", iv, 16);

    std::cout << "Encryption completed.\n";
}

// Decrypt the file by first reading the IV from the input file
void aes_decrypt(const std::string &input_file, const std::string &output_file, unsigned char *key) {
    unsigned char iv[16]; // AES block size is 16 bytes

    EVP_CIPHER_CTX *ctx = EVP_CIPHER_CTX_new();
    if (!ctx) handleErrors();

    std::ifstream ifs(input_file, std::ios::binary);
    std::ofstream ofs(output_file, std::ios::binary);

    if (!ifs.is_open() || !ofs.is_open()) {
        std::cerr << "Error opening file.\n";
        return;
    }

    // Read the IV from the input file
    ifs.read(reinterpret_cast<char*>(iv), sizeof(iv));
    if (ifs.gcount() != sizeof(iv)) {
        std::cerr << "Error reading IV from file.\n";
        return;
    }

    if (1 != EVP_DecryptInit_ex(ctx, EVP_aes_256_cbc(), NULL, key, iv)) handleErrors();

    const size_t buffer_size = 1024;
    std::vector<unsigned char> buffer(buffer_size);
    std::vector<unsigned char> plaintext(buffer_size + EVP_CIPHER_block_size(EVP_aes_256_cbc()));

    int len;
    int plaintext_len = 0;

    while (ifs.read(reinterpret_cast<char*>(buffer.data()), buffer_size) || ifs.gcount()) {
        if (1 != EVP_DecryptUpdate(ctx, plaintext.data(), &len, buffer.data(), ifs.gcount())) handleErrors();
        ofs.write(reinterpret_cast<char*>(plaintext.data()), len);
        plaintext_len += len;
    }

    if (1 != EVP_DecryptFinal_ex(ctx, plaintext.data(), &len)) {
        std::cerr << "Decryption error: incorrect padding or corrupted data.\n";
        handleErrors();
    }
    ofs.write(reinterpret_cast<char*>(plaintext.data()), len);
    plaintext_len += len;

    EVP_CIPHER_CTX_free(ctx);

    // Print key and IV for debugging
    print_hex("Decryption key", key, 32);
    print_hex("Decryption IV", iv, 16);

    std::cout << "Decryption completed.\n";
}
