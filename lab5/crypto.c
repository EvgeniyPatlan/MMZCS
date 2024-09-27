#include <openssl/evp.h>
#include <openssl/rsa.h>
#include <openssl/pem.h>
#include <openssl/rand.h>
#include <openssl/err.h>
#include <openssl/aes.h>
#include <stdio.h>
#include <string.h>
#include <fcntl.h>
#include <unistd.h>
#include <openssl/crypto.h>
#include <time.h>
#include <stdlib.h>

#define AES_KEY_SIZE 256 
#define RSA_KEY_SIZE 2048
#define AES_BLOCK_SIZE 16

void generate_aes_key_and_iv(unsigned char *aes_key, unsigned char *iv) {
    // Перевірка на NULL для aes_key і iv
    if (aes_key == NULL || iv == NULL) {
        fprintf(stderr, "Error: AES key or IV buffer is NULL.\n");
        exit(1);
    }

    int urandom = open("/dev/urandom", O_RDONLY);
    if (urandom < 0) {
        perror("Error opening /dev/urandom");
        exit(1);
    }

    // Читання випадкових байтів для AES ключа і IV
    ssize_t aes_read = read(urandom, aes_key, AES_KEY_SIZE / 8);
    ssize_t iv_read = read(urandom, iv, AES_BLOCK_SIZE);

    // Виведення діагностичних повідомлень
    if (aes_read != AES_KEY_SIZE / 8) {
        fprintf(stderr, "Error: Could not read full AES key from /dev/urandom. Read %zd bytes.\n", aes_read);
    }

    if (iv_read != AES_BLOCK_SIZE) {
        fprintf(stderr, "Error: Could not read full IV from /dev/urandom. Read %zd bytes.\n", iv_read);
    }

    if (aes_read != AES_KEY_SIZE / 8 || iv_read != AES_BLOCK_SIZE) {
        close(urandom);
        exit(1);
    }

    printf("Successfully generated AES key and IV.\n");

    close(urandom);
}
/*
void generate_aes_key_and_iv(unsigned char *aes_key, unsigned char *iv) {
    int urandom = open("/dev/random", O_RDONLY);
    if (urandom < 0) {
        fprintf(stderr, "Error: Could not open /dev/random.\n");
        exit(1);
    }

    if (read(urandom, aes_key, AES_KEY_SIZE / 8) != AES_KEY_SIZE / 8 || 
        read(urandom, iv, AES_BLOCK_SIZE) != AES_BLOCK_SIZE) {
        fprintf(stderr, "Error generating AES key or IV using /dev/random.\n");
        close(urandom);
        exit(1);
    }

    close(urandom);
}

void generate_aes_key_and_iv(unsigned char *aes_key, unsigned char *iv) {
    if (RAND_bytes(aes_key, AES_KEY_SIZE / 8) != 1 || RAND_bytes(iv, AES_BLOCK_SIZE) != 1) {
        fprintf(stderr, "Error generating AES key or IV.\n");
        exit(1);
    }
}

void generate_aes_key_and_iv(unsigned char *aes_key, unsigned char *iv) {
    if (!OPENSSL_init_crypto(0, NULL)) {
        fprintf(stderr, "Error initializing OpenSSL.\n");
        exit(1);
    }

    if (RAND_bytes(aes_key, AES_KEY_SIZE / 8) != 1 || RAND_bytes(iv, AES_BLOCK_SIZE) != 1) {
        fprintf(stderr, "Error generating AES key or IV.\n");
        exit(1);
    }
}
*/

int encrypt_file_aes(const char *input_filename, const char *output_filename, const unsigned char *aes_key, const unsigned char *iv, const EVP_CIPHER *cipher) {
    FILE *input_file = fopen(input_filename, "rb");
    FILE *output_file = fopen(output_filename, "wb");
    if (!input_file || !output_file) {
        fprintf(stderr, "Error opening files.\n");
        return 0;
    }

    unsigned char buffer[AES_BLOCK_SIZE];
    unsigned char ciphertext[AES_BLOCK_SIZE + EVP_MAX_BLOCK_LENGTH];
    int bytes_read, ciphertext_len;

    EVP_CIPHER_CTX *ctx = EVP_CIPHER_CTX_new();
    if (!ctx) {
        fprintf(stderr, "Error initializing encryption context.\n");
        return 0;
    }
    
    if (EVP_EncryptInit_ex(ctx, cipher, NULL, aes_key, iv) != 1) {
        fprintf(stderr, "Error during encryption initialization.\n");
        EVP_CIPHER_CTX_free(ctx);
        return 0;
    }

    while ((bytes_read = fread(buffer, 1, AES_BLOCK_SIZE, input_file)) > 0) {
        if (EVP_EncryptUpdate(ctx, ciphertext, &ciphertext_len, buffer, bytes_read) != 1) {
            fprintf(stderr, "Error during encryption.\n");
            EVP_CIPHER_CTX_free(ctx);
            return 0;
        }
        fwrite(ciphertext, 1, ciphertext_len, output_file);
    }

    if (EVP_EncryptFinal_ex(ctx, ciphertext, &ciphertext_len) != 1) {
        fprintf(stderr, "Error during final encryption step.\n");
        EVP_CIPHER_CTX_free(ctx);
        return 0;
    }
    fwrite(ciphertext, 1, ciphertext_len, output_file);

    EVP_CIPHER_CTX_free(ctx);
    fclose(input_file);
    fclose(output_file);
    return 1;
}

int decrypt_file_aes(const char *input_filename, const char *output_filename, const unsigned char *aes_key, const unsigned char *iv, const EVP_CIPHER *cipher) {
    FILE *input_file = fopen(input_filename, "rb");
    FILE *output_file = fopen(output_filename, "wb");
    if (!input_file || !output_file) {
        fprintf(stderr, "Error opening files.\n");
        return 0;
    }

    unsigned char buffer[AES_BLOCK_SIZE];
    unsigned char plaintext[AES_BLOCK_SIZE + EVP_MAX_BLOCK_LENGTH];
    int bytes_read, plaintext_len;

    EVP_CIPHER_CTX *ctx = EVP_CIPHER_CTX_new();
    if (!ctx) {
        fprintf(stderr, "Error initializing decryption context.\n");
        return 0;
    }

    if (EVP_DecryptInit_ex(ctx, cipher, NULL, aes_key, iv) != 1) {
        fprintf(stderr, "Error during decryption initialization.\n");
        EVP_CIPHER_CTX_free(ctx);
        return 0;
    }

    while ((bytes_read = fread(buffer, 1, AES_BLOCK_SIZE, input_file)) > 0) {
        if (EVP_DecryptUpdate(ctx, plaintext, &plaintext_len, buffer, bytes_read) != 1) {
            fprintf(stderr, "Error during decryption.\n");
            EVP_CIPHER_CTX_free(ctx);
            return 0;
        }
        fwrite(plaintext, 1, plaintext_len, output_file);
    }

    if (EVP_DecryptFinal_ex(ctx, plaintext, &plaintext_len) != 1) {
        fprintf(stderr, "Error during final decryption step.\n");
        EVP_CIPHER_CTX_free(ctx);
        return 0;
    }
    fwrite(plaintext, 1, plaintext_len, output_file);

    EVP_CIPHER_CTX_free(ctx);
    fclose(input_file);
    fclose(output_file);
    return 1;
}

int generate_rsa_key_pair(const char *private_key_file, const char *public_key_file) {
    RSA *rsa = RSA_new();
    BIGNUM *bne = BN_new();
    if (BN_set_word(bne, RSA_F4) != 1) {
        fprintf(stderr, "Error setting BIGNUM.\n");
        return 0;
    }

    if (RSA_generate_key_ex(rsa, RSA_KEY_SIZE, bne, NULL) != 1) {
        fprintf(stderr, "Error generating RSA key pair.\n");
        RSA_free(rsa);
        BN_free(bne);
        return 0;
    }

    BIO *private_bio = BIO_new_file(private_key_file, "w");
    BIO *public_bio = BIO_new_file(public_key_file, "w");
    if (!private_bio || !public_bio) {
        fprintf(stderr, "Error opening key files for writing.\n");
        RSA_free(rsa);
        BN_free(bne);
        return 0;
    }

    if (!PEM_write_bio_RSAPrivateKey(private_bio, rsa, NULL, NULL, 0, NULL, NULL) || !PEM_write_bio_RSAPublicKey(public_bio, rsa)) {
        fprintf(stderr, "Error writing RSA keys.\n");
        RSA_free(rsa);
        BIO_free(private_bio);
        BIO_free(public_bio);
        return 0;
    }

    BIO_free(private_bio);
    BIO_free(public_bio);
    RSA_free(rsa);
    BN_free(bne);
    return 1;
}

int encrypt_aes_key_with_rsa(const char *public_key_file, const unsigned char *aes_key, unsigned char *encrypted_key) {
    BIO *public_bio = BIO_new_file(public_key_file, "r");
    if (!public_bio) {
        fprintf(stderr, "Error: Could not open public key file %s.\n", public_key_file);
        return 0;
    }

    RSA *rsa = PEM_read_bio_RSAPublicKey(public_bio, NULL, NULL, NULL);
    if (!rsa) {
        fprintf(stderr, "Error: Could not read public key from file %s.\n", public_key_file);
        BIO_free(public_bio);
        return 0;
    }

    int rsa_size = RSA_size(rsa);
    if (rsa_size != RSA_KEY_SIZE / 8) {
        fprintf(stderr, "Error: Incorrect RSA key size. Expected %d, got %d.\n", RSA_KEY_SIZE / 8, rsa_size);
        RSA_free(rsa);
        BIO_free(public_bio);
        return 0;
    }

    int encrypted_len = RSA_public_encrypt(AES_KEY_SIZE / 8, aes_key, encrypted_key, rsa, RSA_PKCS1_OAEP_PADDING);
    if (encrypted_len == -1) {
        fprintf(stderr, "Error: RSA encryption failed.\n");
        ERR_print_errors_fp(stderr);
    } else {
        printf("RSA encryption succeeded. Encrypted length: %d bytes.\n", encrypted_len);
    }

    RSA_free(rsa);
    BIO_free(public_bio);
    return encrypted_len;
}

int decrypt_aes_key_with_rsa(const char *private_key_file, const unsigned char *encrypted_key, unsigned char *aes_key) {
    BIO *private_bio = BIO_new_file(private_key_file, "r");
    if (!private_bio) {
        fprintf(stderr, "Error: Could not open private key file %s.\n", private_key_file);
        return 0;
    }

    RSA *rsa = PEM_read_bio_RSAPrivateKey(private_bio, NULL, NULL, NULL);
    if (!rsa) {
        fprintf(stderr, "Error: Could not read private key from file %s.\n", private_key_file);
        BIO_free(private_bio);
        return 0;
    }

    int rsa_size = RSA_size(rsa);
    if (rsa_size != RSA_KEY_SIZE / 8) {
        fprintf(stderr, "Error: Incorrect RSA key size. Expected %d, got %d.\n", RSA_KEY_SIZE / 8, rsa_size);
        RSA_free(rsa);
        BIO_free(private_bio);
        return 0;
    }

    memset(aes_key, 0, AES_KEY_SIZE / 8);

    int decrypted_len = RSA_private_decrypt(rsa_size, encrypted_key, aes_key, rsa, RSA_PKCS1_OAEP_PADDING);
    if (decrypted_len == -1) {
        fprintf(stderr, "Error: RSA decryption failed.\n");
        ERR_print_errors_fp(stderr);
    } else {
        printf("RSA decryption succeeded. Decrypted length: %d bytes.\n", decrypted_len);
    }

    RSA_free(rsa);
    BIO_free(private_bio);
    return decrypted_len;
}

#ifndef TEST_MODE

int main() {
    unsigned char aes_key[AES_KEY_SIZE / 8];
    unsigned char iv[AES_BLOCK_SIZE];
    const EVP_CIPHER *cipher = EVP_aes_256_cbc();

    generate_aes_key_and_iv(aes_key, iv);

    encrypt_file_aes("test_input.txt", "test_encrypted.bin", aes_key, iv, cipher);
    decrypt_file_aes("test_encrypted.bin", "test_output.txt", aes_key, iv, cipher);

    return 0;
}

#endif
