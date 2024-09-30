
# Lab 4: AES-256 File Encryption and Decryption

## Introduction
This lab focuses on implementing file encryption and decryption using AES-256 in CBC mode, with a password-based key derivation using SHA-256 hashing. OpenSSL is used for cryptographic operations, while C++ manages file I/O.

## Objective
- Encrypt and decrypt files securely using AES-256 CBC mode.
- Derive an AES-256 key from the user’s password via SHA-256 hashing.

---

## How the Code Works

### 1. Password-Based Key Derivation (`sha256`)
The user enters a password, which is hashed using SHA-256 to derive a 32-byte AES-256 key. This function uses OpenSSL’s `EVP_MD_CTX` API to perform hashing.

**Steps:**
- Initializes a digest context with `EVP_DigestInit_ex`.
- Updates the context with the password data using `EVP_DigestUpdate`.
- Retrieves the final hash using `EVP_DigestFinal_ex`.

### 2. AES Encryption (`aes_encrypt`)
- **Initialization**: A 16-byte IV (Initialization Vector) is generated randomly using `RAND_bytes` to ensure randomness in encryption.
- **File Encryption**: The input file is read in blocks, encrypted using AES-256 CBC, and the result is written to the output file.
- **IV Storage**: The IV is prepended to the output file, which is crucial for successful decryption later.

**Steps:**
- OpenSSL's `EVP_EncryptInit_ex` initializes the AES encryption context.
- Data is encrypted in chunks with `EVP_EncryptUpdate`.
- The final encryption block is handled by `EVP_EncryptFinal_ex`, ensuring padding for AES.
- Writes the encrypted data and IV to the output file.

### 3. AES Decryption (`aes_decrypt`)
- **Reading IV**: The IV is extracted from the beginning of the encrypted file.
- **File Decryption**: The remaining encrypted content is decrypted using the previously read IV and the AES-256 key.

**Steps:**
- Uses `EVP_DecryptInit_ex` to initialize the decryption context with the key and IV.
- Decrypts in chunks using `EVP_DecryptUpdate`.
- Handles the final decrypted block with `EVP_DecryptFinal_ex`.

The decrypted data is then written to the output file.

### 4. Main Program Logic
- Prompts the user to provide a password, operation (`encrypt` or `decrypt`), input file, and output file.
- The program hashes the password to derive the AES-256 key.
- Depending on the user’s choice, either `aes_encrypt` or `aes_decrypt` is invoked.
- Upon successful encryption or decryption, the program outputs a success message.

---

## Example Workflow
1. **Encryption**:
   - The password is hashed to derive the AES-256 key.
   - The input file is encrypted with AES-256 CBC, and the IV is prepended to the output file.

2. **Decryption**:
   - The IV is read from the encrypted file.
   - The file is decrypted using AES-256 CBC and the derived key.

---

## How to Run
1. **Compile the Program**:
   ```
      make
   ```

2. **Run the Encryption**:
   ```
   ./aes_crypto_app
   ```

3. **Run the Decryption**:
   ```
   ./aes_crypto_app
   ```

## Conclusion
This lab demonstrates a secure way to encrypt and decrypt files using AES-256 CBC. The use of password-based key derivation ensures that the encryption key is securely tied to the user's input, while the IV ensures non-deterministic encryption, making each operation unique.
