**Lab Work No. 8: Secure Data Exchange Using PGP and GnuPG**

**Objective:** Learn how to use GnuPG for creating key pairs, encrypting, signing, and securely exchanging files between users. Understand the process of key management, symmetric and asymmetric encryption, and file verification.

**Theoretical Background**

PGP (Pretty Good Privacy) is a data encryption and decryption program that provides cryptographic privacy and authentication for secure communication. GnuPG (GPG) is a free implementation of the OpenPGP standard that allows encrypting files and emails, signing them, and managing keys.

**Key Concepts**:
- **Asymmetric Encryption**: Uses a pair of keys (public and private) for secure communication. The public key is used for encryption, while the private key is used for decryption.
- **Symmetric Encryption**: Uses a single shared secret key for both encryption and decryption.
- **Digital Signature**: Ensures data integrity and authenticity by using the sender's private key to create a signature, which can be verified with the sender's public key.

**Implementation Description**

A Bash script (`pgp_script.sh`) was created to simulate secure file exchange between two users using GnuPG. The script performs the following steps:

1. **Key Generation**:
   - Generates RSA key pairs (2048 bits) for both the user and their neighbor.
   - Saves keys in the appropriate directories (`keys/$YOUR_NAME`, `keys/$NEIGHBOR_NAME`).

2. **Public Key Exchange**:
   - Exports the public keys for both users to a shared exchange directory (`exchange`).
   - Each user imports the other's public key for use in encryption.

3. **Encryption and Signing Operations**:
   - **Encrypt**: User encrypts a file (`Hello1.txt`) using the neighbor's public key to ensure only the neighbor can decrypt it.
   - **Sign**: User signs another file (`Hello2.txt`) using their private key to allow verification of authorship.
   - **Symmetric Encryption**: A third file (`Hello3.txt`) is encrypted using a symmetric key for simple secure storage.
   - **Encrypt and Sign**: A fourth file (`Hello4.txt`) is both encrypted (with the neighbor's public key) and signed to provide confidentiality and authenticity.

4. **File Exchange Simulation**:
   - Moves the encrypted and signed files to the shared `exchange` directory to simulate file sharing.

5. **Decryption and Verification**:
   - Neighbor decrypts the received files and verifies the signed file to ensure integrity and authenticity.

6. **Trust Establishment**:
   - Neighbor signs the user's public key to establish a trust relationship, indicating that they trust the user's identity.

**How the Program Works**

1. **User and Neighbor Setup**:
   - The script prompts for the names of the user and their neighbor.
   - Directories for keys, files, and exchange are created, with proper permissions set.

2. **Key Generation**:
   - RSA key pairs are generated for both the user and their neighbor without passphrase protection for simplicity.

3. **File Operations**:
   - Four files (`Hello1.txt`, `Hello2.txt`, `Hello3.txt`, `Hello4.txt`) are created and processed with GPG commands to demonstrate encryption, signing, symmetric encryption, and combined operations.

4. **Exchange and Verification**:
   - The neighbor decrypts and verifies the files received in the `exchange` directory.

**How to Run the Script**

1. **Requirements**:
   - Install GnuPG (`sudo apt-get install gnupg`).
   - Ensure Bash is available in your Linux environment.

2. **Running the Script**:
   - Run the script with the command: `./pgp_script.sh`.
   - Follow the prompts to enter user names.

**Test Results**

The script successfully generated RSA key pairs, exported and imported public keys, encrypted and signed files, and simulated secure file exchange between two users. Each file was correctly decrypted or verified by the neighbor, demonstrating secure data exchange using GPG.

**Conclusions**

This lab provided hands-on experience with PGP encryption, key management, digital signatures, and secure file exchange. The use of GnuPG showcased how asymmetric and symmetric encryption can be combined to provide confidentiality, integrity, and authenticity in communications. Establishing trust through key signing further illustrated the importance of verifying identities in secure exchanges.

