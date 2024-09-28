#!/bin/bash

# Input for user's and neighbor's names
echo "Enter your name:"
read YOUR_NAME
echo "Enter your neighbor's name:"
read NEIGHBOR_NAME

# Create directories for each user and a shared directory for file exchange
mkdir -p users/$YOUR_NAME keys/$YOUR_NAME files/$YOUR_NAME exchange
mkdir -p users/$NEIGHBOR_NAME keys/$NEIGHBOR_NAME files/$NEIGHBOR_NAME

# Fix directory permissions
chmod 700 keys/$YOUR_NAME
chmod 700 keys/$NEIGHBOR_NAME

# 1. Generate key pairs for both users
echo "Generating keys for $YOUR_NAME..."
gpg --batch --gen-key <<EOF
Key-Type: RSA
Key-Length: 2048
Name-Real: $YOUR_NAME
Name-Email: $YOUR_NAME@example.com
Expire-Date: 0
%no-protection
%commit
EOF

echo "Generating keys for $NEIGHBOR_NAME..."
gpg --batch --gen-key <<EOF
Key-Type: RSA
Key-Length: 2048
Name-Real: $NEIGHBOR_NAME
Name-Email: $NEIGHBOR_NAME@example.com
Expire-Date: 0
%no-protection
%commit
EOF

# 2. Export public keys to files
echo "Exporting $YOUR_NAME's public key..."
gpg --armor --export $YOUR_NAME@example.com > exchange/pub_$YOUR_NAME.gpg

echo "Exporting $NEIGHBOR_NAME's public key..."
gpg --armor --export $NEIGHBOR_NAME@example.com > exchange/pub_$NEIGHBOR_NAME.gpg

# 3. Export secret keys (optional)
echo "Exporting $YOUR_NAME's secret key..."
gpg --armor --export-secret-keys $YOUR_NAME@example.com > users/$YOUR_NAME/sec_$YOUR_NAME.gpg

# 4. Import public keys
echo "$NEIGHBOR_NAME is importing $YOUR_NAME's public key..."
gpg --import exchange/pub_$YOUR_NAME.gpg

echo "$YOUR_NAME is importing $NEIGHBOR_NAME's public key..."
gpg --import exchange/pub_$NEIGHBOR_NAME.gpg

# 5. Encrypt the file "Hello1.txt" using the neighbor's public key
echo "$YOUR_NAME is encrypting the file Hello1.txt using $NEIGHBOR_NAME's public key..."
echo "Hello, this is a test file for encryption." > files/$YOUR_NAME/Hello1.txt
gpg --encrypt --recipient $NEIGHBOR_NAME@example.com --output files/$YOUR_NAME/Hello1.txt.gpg files/$YOUR_NAME/Hello1.txt

# 6. Sign the file "Hello2.txt" using your private key
echo "$YOUR_NAME is signing the file Hello2.txt..."
echo "Hello, this is a test file for signing." > files/$YOUR_NAME/Hello2.txt
gpg --sign --output files/$YOUR_NAME/Hello2.txt.gpg files/$YOUR_NAME/Hello2.txt

# 7. Symmetrically encrypt the file "Hello3.txt"
echo "$YOUR_NAME is symmetrically encrypting the file Hello3.txt..."
echo "Hello, this is a test file for symmetric encryption." > files/$YOUR_NAME/Hello3.txt
gpg --symmetric --output files/$YOUR_NAME/Hello3.txt.gpg files/$YOUR_NAME/Hello3.txt

# 8. Encrypt and sign the file "Hello4.txt"
echo "$YOUR_NAME is encrypting and signing the file Hello4.txt..."
echo "Hello, this is a test file for encryption and signing." > files/$YOUR_NAME/Hello4.txt
gpg --encrypt --sign --recipient $NEIGHBOR_NAME@example.com --output files/$YOUR_NAME/Hello4.txt.gpg files/$YOUR_NAME/Hello4.txt

# 9. Simulate file exchange: Move files to the exchange folder
mv files/$YOUR_NAME/Hello1.txt.gpg exchange/
mv files/$YOUR_NAME/Hello2.txt.gpg exchange/
mv files/$YOUR_NAME/Hello3.txt.gpg exchange/
mv files/$YOUR_NAME/Hello4.txt.gpg exchange/

# 10. Neighbor decrypts and verifies the received files
echo "$NEIGHBOR_NAME is decrypting the received files..."
gpg --decrypt --output files/$NEIGHBOR_NAME/Hello1_decrypted.txt exchange/Hello1.txt.gpg
gpg --verify exchange/Hello2.txt.gpg --output files/$NEIGHBOR_NAME/Hello2_verified.txt
gpg --decrypt --output files/$NEIGHBOR_NAME/Hello3_decrypted.txt exchange/Hello3.txt.gpg
gpg --decrypt --output files/$NEIGHBOR_NAME/Hello4_decrypted.txt exchange/Hello4.txt.gpg

# 11. Trust relationship: Neighbor signs your public key
echo "$NEIGHBOR_NAME is signing $YOUR_NAME's public key..."
gpg --sign-key $YOUR_NAME@example.com

# Completion message
echo "File exchange and trust setup between $YOUR_NAME and $NEIGHBOR_NAME is complete!"

