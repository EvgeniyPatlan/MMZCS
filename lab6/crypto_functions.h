#ifndef CRYPTO_FUNCTIONS_H
#define CRYPTO_FUNCTIONS_H

// Function declarations for encryption and decryption
void create_encrypted_message(const char* input_file, const char* output_file, const char* cert_file);
void decrypt_message(const char* encrypted_file, const char* decrypted_file, const char* key_file, const char* cert_file);

#endif // CRYPTO_FUNCTIONS_H
