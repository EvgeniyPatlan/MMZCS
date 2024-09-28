#!/bin/bash

# Help message
if [[ "$1" == "--help" ]]; then
    echo "Usage: ./test_script.sh"
    echo "This script tests if the 'generate_certs.sh' script successfully generates the required certificates."
    echo "It checks the presence and validity of CA, User A, and User B certificates."
    exit 0
fi

# Run the certificate generation script
./generate_certs.sh

# Check if all required files are generated
if [[ -f "./certs/ca_key.pem" && -f "./certs/ca_cert.pem" && \
      -f "./certs/userA_key.pem" && -f "./certs/userA_cert.p12" && \
      -f "./certs/userB_key.pem" && -f "./certs/userB_cert.p12" ]]; then
    echo "Success: All certificates have been generated."
else
    echo "Error: Some certificates were not generated."
    exit 1
fi

# Check if the CA certificate is valid
openssl x509 -in "./certs/ca_cert.pem" -noout || { echo "Error: CA certificate is invalid."; exit 1; }

# Check if User A's certificate is valid
openssl pkcs12 -info -in "./certs/userA_cert.p12" -password pass:userAPass -noout || { echo "Error: User A's certificate is invalid."; exit 1; }

# Check if User B's certificate is valid
openssl pkcs12 -info -in "./certs/userB_cert.p12" -password pass:userBPass -noout || { echo "Error: User B's certificate is invalid."; exit 1; }

echo "All tests passed successfully!"
