#!/bin/bash

# Generate PKCS#12 format file for User 1
openssl pkcs12 -export -out user1.p12 -inkey user1_key.pem -in user1_cert.pem -certfile serv_cert.pem -passout pass:password

# Generate PKCS#12 format file for User 2
openssl pkcs12 -export -out user2.p12 -inkey user2_key.pem -in user2_cert.pem -certfile serv_cert.pem -passout pass:password

echo "PKCS#12 files for user1 and user2 have been generated."

