#!/bin/bash

# Create a random seed file to avoid RNG errors
RANDFILE=/root/.rnd
if [ ! -f "$RANDFILE" ]; then
    echo "Creating random seed file..."
    openssl rand -writerand $RANDFILE
fi

# Remove any old certificate and key
rm -f serv_key.pem serv_cert.pem user1_key.pem user1_cert.pem user2_key.pem user2_cert.pem

# Generate a new RSA private key for the server
openssl genpkey -algorithm RSA -out serv_key.pem

# Generate a new self-signed certificate using the private key for the server
openssl req -new -x509 -key serv_key.pem -out serv_cert.pem -days 365 -subj "/CN=localhost"

# Generate a new RSA private key and certificate for user1
openssl genpkey -algorithm RSA -out user1_key.pem
openssl req -new -key user1_key.pem -out user1.csr -subj "/CN=User1"
openssl x509 -req -in user1.csr -CA serv_cert.pem -CAkey serv_key.pem -CAcreateserial -out user1_cert.pem -days 365

# Generate a new RSA private key and certificate for user2
openssl genpkey -algorithm RSA -out user2_key.pem
openssl req -new -key user2_key.pem -out user2.csr -subj "/CN=User2"
openssl x509 -req -in user2.csr -CA serv_cert.pem -CAkey serv_key.pem -CAcreateserial -out user2_cert.pem -days 365

echo "Server, user1, and user2 certificates and keys generated."

