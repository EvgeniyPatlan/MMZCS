#!/bin/bash

# Check if OpenSSL is installed
if ! command -v openssl &> /dev/null
then
    echo "OpenSSL not found. Please install OpenSSL."
    exit
fi

# Help message
if [[ "$1" == "--help" ]]; then
    echo "Usage: ./generate_certs.sh"
    echo "This script generates the following certificates:"
    echo "1. A self-signed CA certificate"
    echo "2. RSA key pairs and certificates for two users (User A and User B)"
    echo "3. PKCS#12 formatted certificates for each user"
    exit 0
fi

# Directory for storing certificates
CERT_DIR="./certs"
mkdir -p $CERT_DIR

# Key and certificate parameters
KEY_SIZE=2048
DAYS_VALID=365

# File paths for CA key and certificate
CA_KEY="$CERT_DIR/ca_key.pem"
CA_CERT="$CERT_DIR/ca_cert.pem"

# User A files
USER_A_KEY="$CERT_DIR/userA_key.pem"
USER_A_CSR="$CERT_DIR/userA_csr.pem"
USER_A_CERT="$CERT_DIR/userA_cert.pem"
USER_A_P12="$CERT_DIR/userA_cert.p12"

# User B files
USER_B_KEY="$CERT_DIR/userB_key.pem"
USER_B_CSR="$CERT_DIR/userB_csr.pem"
USER_B_CERT="$CERT_DIR/userB_cert.pem"
USER_B_P12="$CERT_DIR/userB_cert.p12"

# Generate CA key and self-signed certificate
echo "Generating CA key pair..."
openssl genpkey -algorithm RSA -out $CA_KEY -pkeyopt rsa_keygen_bits:$KEY_SIZE
echo "Generating self-signed CA certificate..."
openssl req -x509 -new -key $CA_KEY -out $CA_CERT -days $DAYS_VALID -subj "/C=UA/ST=Kyiv/L=Kyiv/O=MyOrg/OU=MyDept/CN=MyCA"

# Generate User A's key and certificate
echo "Generating User A's key pair..."
openssl genpkey -algorithm RSA -out $USER_A_KEY -pkeyopt rsa_keygen_bits:$KEY_SIZE
echo "Generating User A's certificate signing request..."
openssl req -new -key $USER_A_KEY -out $USER_A_CSR -subj "/C=UA/ST=Kyiv/L=Kyiv/O=MyOrg/OU=MyDept/CN=UserA"
echo "Signing User A's certificate with CA..."
openssl x509 -req -in $USER_A_CSR -CA $CA_CERT -CAkey $CA_KEY -CAcreateserial -out $USER_A_CERT -days $DAYS_VALID

# Export User A's certificate in PKCS#12 format
echo "Exporting User A's certificate to PKCS#12 format..."
openssl pkcs12 -export -out $USER_A_P12 -inkey $USER_A_KEY -in $USER_A_CERT -password pass:userAPass

# Generate User B's key and certificate
echo "Generating User B's key pair..."
openssl genpkey -algorithm RSA -out $USER_B_KEY -pkeyopt rsa_keygen_bits:$KEY_SIZE
echo "Generating User B's certificate signing request..."
openssl req -new -key $USER_B_KEY -out $USER_B_CSR -subj "/C=UA/ST=Kyiv/L=Kyiv/O=MyOrg/OU=MyDept/CN=UserB"
echo "Signing User B's certificate with CA..."
openssl x509 -req -in $USER_B_CSR -CA $CA_CERT -CAkey $CA_KEY -CAcreateserial -out $USER_B_CERT -days $DAYS_VALID

# Export User B's certificate in PKCS#12 format
echo "Exporting User B's certificate to PKCS#12 format..."
openssl pkcs12 -export -out $USER_B_P12 -inkey $USER_B_KEY -in $USER_B_CERT -password pass:userBPass

echo "Certificates successfully generated and saved in $CERT_DIR"
