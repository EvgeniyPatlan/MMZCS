#include <iostream>
#include "crypto_functions.h"

int main() {
    // Example: create and decrypt message
    create_encrypted_message("message.txt", "encrypted_message.txt", "certs/userA_cert.pem");
    decrypt_message("encrypted_message.txt", "decrypted_message.txt", "certs/userA_key.pem", "certs/userA_cert.pem");

    return 0;
}
