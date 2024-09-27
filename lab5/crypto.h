#ifndef CRYPTO_H
#define CRYPTO_H

#include <openssl/evp.h>

#define AES_KEY_SIZE 256  
#define RSA_KEY_SIZE 2048
#define AES_BLOCK_SIZE 16

void generate_aes_key_and_iv(unsigned char *aes_key, unsigned char *iv);
int encrypt_file_aes(const char *input_filename, const char *output_filename, const unsigned char *aes_key, const unsigned char *iv, const EVP_CIPHER *cipher);
int decrypt_file_aes(const char *input_filename, const char *output_filename, const unsigned char *aes_key, const unsigned char *iv, const EVP_CIPHER *cipher);

int generate_rsa_key_pair(const char *private_key_file, const char *public_key_file);
int encrypt_aes_key_with_rsa(const char *public_key_file, const unsigned char *aes_key, unsigned char *encrypted_key);
int decrypt_aes_key_with_rsa(const char *private_key_file, const unsigned char *encrypted_key, unsigned char *aes_key);

#endif // CRYPTO_H
