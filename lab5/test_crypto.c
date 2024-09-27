#include <CUnit/Basic.h>
#include "crypto.h"
#include <sys/stat.h>

int file_exists(const char *filename) {
    struct stat buffer;
    return (stat(filename, &buffer) == 0);
}

void test_generate_aes_key_and_iv() {
    unsigned char aes_key[AES_KEY_SIZE / 8];
    unsigned char iv[AES_BLOCK_SIZE];
    generate_aes_key_and_iv(aes_key, iv);

    CU_ASSERT(aes_key[0] != 0);
    CU_ASSERT(iv[0] != 0);
}

void test_encrypt_decrypt_aes() {
    const char *input_file = "test_input.txt";
    const char *encrypted_file = "test_encrypted.bin";
    const char *decrypted_file = "test_output.txt";
    unsigned char aes_key[AES_KEY_SIZE / 8];
    unsigned char iv[AES_BLOCK_SIZE];
    const EVP_CIPHER *cipher = EVP_aes_256_cbc();

    generate_aes_key_and_iv(aes_key, iv);

    CU_ASSERT_TRUE(file_exists(input_file));

    CU_ASSERT(encrypt_file_aes(input_file, encrypted_file, aes_key, iv, cipher) == 1);

    CU_ASSERT_TRUE(file_exists(encrypted_file));

    CU_ASSERT(decrypt_file_aes(encrypted_file, decrypted_file, aes_key, iv, cipher) == 1);

    CU_ASSERT_TRUE(file_exists(decrypted_file));

    FILE *input_f = fopen(input_file, "r");
    FILE *output_f = fopen(decrypted_file, "r");
    CU_ASSERT_PTR_NOT_NULL(input_f);
    CU_ASSERT_PTR_NOT_NULL(output_f);

    char input_buf[256], output_buf[256];
    while (fgets(input_buf, sizeof(input_buf), input_f) != NULL) {
        CU_ASSERT_PTR_NOT_NULL(fgets(output_buf, sizeof(output_buf), output_f));
        CU_ASSERT_STRING_EQUAL(input_buf, output_buf);
    }

    fclose(input_f);
    fclose(output_f);
}

void test_generate_rsa_key_pair() {
    CU_ASSERT(generate_rsa_key_pair("test_private_key.pem", "test_public_key.pem") == 1);
}

void test_rsa_encrypt_decrypt_aes_key() {
    unsigned char aes_key[AES_KEY_SIZE / 8];
    unsigned char encrypted_aes_key[RSA_KEY_SIZE / 8];
    unsigned char iv[AES_BLOCK_SIZE];

    generate_aes_key_and_iv(aes_key, iv);

    if (generate_rsa_key_pair("test_private_key.pem", "test_public_key.pem") != 1) {
        printf("Error generating RSA key pair.\n");
        CU_FAIL("RSA key generation failed");
        return;
    }

    if (!file_exists("test_private_key.pem") || !file_exists("test_public_key.pem")) {
        printf("Error: RSA key files do not exist.\n");
        CU_FAIL("RSA key files do not exist");
        return;
    }

    int encrypted_len = encrypt_aes_key_with_rsa("test_public_key.pem", aes_key, encrypted_aes_key);
    if (encrypted_len <= 0) {
        printf("Error: AES key encryption failed.\n");
        CU_FAIL("AES key encryption failed");
        return;
    } else {
        printf("AES key encryption succeeded. Encrypted length: %d bytes.\n", encrypted_len);
    }

    int decrypted_len = decrypt_aes_key_with_rsa("test_private_key.pem", encrypted_aes_key, aes_key);
    if (decrypted_len <= 0) {
        printf("Error: AES key decryption failed.\n");
        CU_FAIL("AES key decryption failed");
        return;
    } else {
        printf("AES key decryption succeeded. Decrypted length: %d bytes.\n", decrypted_len);
    }
}

int main() {
    CU_initialize_registry();

    CU_pSuite pSuite = CU_add_suite("CryptoTests", 0, 0);
    CU_add_test(pSuite, "test_generate_aes_key_and_iv", test_generate_aes_key_and_iv);
    CU_add_test(pSuite, "test_encrypt_decrypt_aes", test_encrypt_decrypt_aes);
    CU_add_test(pSuite, "test_generate_rsa_key_pair", test_generate_rsa_key_pair);
    CU_add_test(pSuite, "test_rsa_encrypt_decrypt_aes_key", test_rsa_encrypt_decrypt_aes_key);

    CU_basic_set_mode(CU_BRM_VERBOSE);
    CU_basic_run_tests();
    CU_cleanup_registry();

    return CU_get_error();
}
