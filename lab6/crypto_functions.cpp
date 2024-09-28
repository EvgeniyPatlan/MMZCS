#include <openssl/cms.h>
#include <openssl/pem.h>
#include <openssl/err.h>
#include <openssl/x509.h>
#include <iostream>

void log_openssl_error() {
    ERR_print_errors_fp(stderr);
}

void create_encrypted_message(const char* input_file, const char* output_file, const char* cert_file) {
    // Open input file for reading
    BIO *in = BIO_new_file(input_file, "r");
    // Open output file for writing
    BIO *out = BIO_new_file(output_file, "w");
    // Open certificate file for reading
    BIO *cert = BIO_new_file(cert_file, "r");

    if (!in) {
        std::cerr << "Failed to open input file: " << input_file << std::endl;
        return;
    }
    if (!out) {
        std::cerr << "Failed to create output file: " << output_file << std::endl;
        return;
    }
    if (!cert) {
        std::cerr << "Failed to open certificate file: " << cert_file << std::endl;
        return;
    }

    // Read recipient certificate
    X509 *recip = PEM_read_bio_X509(cert, NULL, NULL, NULL);
    if (!recip) {
        std::cerr << "Error reading recipient certificate from file: " << cert_file << std::endl;
        log_openssl_error();
        BIO_free_all(in);
        BIO_free_all(out);
        BIO_free_all(cert);
        return;
    }

    // Add recipient to a list
    STACK_OF(X509) *recipients = sk_X509_new_null();
    sk_X509_push(recipients, recip);

    // Encrypt the message
    CMS_ContentInfo *cms = CMS_encrypt(recipients, in, EVP_aes_128_cbc(), CMS_STREAM);
    if (!cms) {
        std::cerr << "Error creating CMS encrypted message" << std::endl;
        log_openssl_error();
        sk_X509_pop_free(recipients, X509_free);
        X509_free(recip);
        BIO_free_all(in);
        BIO_free_all(out);
        BIO_free_all(cert);
        return;
    }

    // Write encrypted data to output file in SMIME format
    if (!SMIME_write_CMS(out, cms, in, CMS_STREAM)) {
        std::cerr << "Error writing encrypted message to file: " << output_file << std::endl;
        log_openssl_error();
    } else {
        std::cout << "Message successfully encrypted and saved to " << output_file << std::endl;
    }

    CMS_ContentInfo_free(cms);
    sk_X509_pop_free(recipients, X509_free);
    X509_free(recip);
    BIO_free_all(in);
    BIO_free_all(out);
    BIO_free_all(cert);
}

void decrypt_message(const char* encrypted_file, const char* decrypted_file, const char* key_file, const char* cert_file) {
    // Open files for reading and writing
    BIO *in = BIO_new_file(encrypted_file, "r");
    BIO *out = BIO_new_file(decrypted_file, "w");
    BIO *key = BIO_new_file(key_file, "r");
    BIO *cert = BIO_new_file(cert_file, "r");

    if (!in) {
        std::cerr << "Failed to open encrypted file: " << encrypted_file << std::endl;
        return;
    }
    if (!out) {
        std::cerr << "Failed to create decrypted file: " << decrypted_file << std::endl;
        return;
    }
    if (!key) {
        std::cerr << "Failed to open key file: " << key_file << std::endl;
        return;
    }
    if (!cert) {
        std::cerr << "Failed to open certificate file: " << cert_file << std::endl;
        return;
    }

    // Read certificate and private key
    X509 *recip = PEM_read_bio_X509(cert, NULL, NULL, NULL);
    EVP_PKEY *pkey = PEM_read_bio_PrivateKey(key, NULL, NULL, NULL);

    if (!recip) {
        std::cerr << "Error reading recipient certificate" << std::endl;
        log_openssl_error();
        BIO_free_all(in);
        BIO_free_all(out);
        BIO_free_all(key);
        BIO_free_all(cert);
        return;
    }
    if (!pkey) {
        std::cerr << "Error reading private key" << std::endl;
        log_openssl_error();
        BIO_free_all(in);
        BIO_free_all(out);
        BIO_free_all(key);
        BIO_free_all(cert);
        return;
    }

    // Read encrypted CMS content in SMIME format
    CMS_ContentInfo *cms = SMIME_read_CMS(in, NULL);
    if (!cms) {
        std::cerr << "Error reading CMS encrypted message from file: " << encrypted_file << std::endl;
        log_openssl_error();
        EVP_PKEY_free(pkey);
        X509_free(recip);
        BIO_free_all(in);
        BIO_free_all(out);
        BIO_free_all(key);
        BIO_free_all(cert);
        return;
    }

    // Decrypt the CMS message
    if (!CMS_decrypt(cms, pkey, recip, NULL, out, 0)) {
        std::cerr << "Error decrypting message" << std::endl;
        log_openssl_error();
    } else {
        std::cout << "Message successfully decrypted and saved to " << decrypted_file << std::endl;
    }

    CMS_ContentInfo_free(cms);
    EVP_PKEY_free(pkey);
    X509_free(recip);
    BIO_free_all(in);
    BIO_free_all(out);
    BIO_free_all(key);
    BIO_free_all(cert);
}

