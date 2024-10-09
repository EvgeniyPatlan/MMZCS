**Lab Work No. 5: Symmetric and Asymmetric Data Encryption Using the OpenSSL Cryptographic Toolkit**

**Objective:** Familiarize yourself with symmetric and asymmetric encryption using OpenSSL and develop a C/C++ application for data encryption and decryption.

**Theoretical Background**

OpenSSL is a powerful cryptographic tool that allows generating keys, encrypting data, creating digital signatures, etc. This lab focuses on symmetric encryption (AES) and asymmetric encryption (RSA).

**AES Algorithm** (Advanced Encryption Standard) is a block symmetric cipher. In this lab, AES-128/192/256 is used in CBC (Cipher Block Chaining) and CFB (Cipher Feedback) modes, which enhances data security by using pseudorandomly generated keys and initialization vectors.

**RSA Algorithm** is used to generate a key pair: public and private keys. These keys are stored in PEM format and are used to encrypt AES session keys, ensuring secure key exchange between parties.

**Implementation Description**

A console application in C was developed using the OpenSSL libraries. The application includes the following functions:

- **File encryption and decryption** using AES. The user selects the mode (CBC or CFB) and a key, which is either pseudorandomly generated or imported.
- **RSA key pair generation** (2048 bits), saving the keys in PEM format files.
- **AES session key encryption** using the RSA public key and decryption using the private key to recover the encrypted file.

**How the Program Works**

1. **Mode Selection**: When launched, the program asks the user which encryption mode to use — AES (CBC or CFB) or RSA for session key encryption.
2. **Key Generation**: The program generates an AES session key and an initialization vector, as well as an RSA key pair for asymmetric encryption. The user can choose to generate a key automatically or import their own.
3. **File Encryption**: The selected file is encrypted using AES, and the generated session key is encrypted with RSA for secure storage and transmission.
4. **Decryption**: To recover the file, the RSA private key is used to decrypt the AES session key, after which the file itself is decrypted.
5. **Saving Results**: Encrypted and decrypted files are saved in a user-specified location, and keys are saved in PEM files for further use.

**How to Build and Run the Program**

1. **Building the Program**:
   - Install OpenSSL. Run the command: `sudo apt-get install libssl-dev` (for Ubuntu) or use other suitable methods for your OS.
   - Use the Makefile included in the project. In the terminal, navigate to the project directory and run: `make`. This will automatically generate the executable file.
   - The Makefile includes the following main commands:
     - `make all` — compiles all necessary files to create the executable.
     - `make clean` — removes all object files and executables created during compilation.
     - `make test` — runs the program's tests using test files to verify the correctness of the encryption and decryption algorithms.

2. **Running the Program**:
   - After successful compilation, run the executable file with the command: `./crypto_app` (the filename depends on the Makefile).
   - During execution, the program prompts the user for the operation mode, the file to encrypt/decrypt, and other necessary parameters.

**Running Tests**

1. **Testing Encryption and Decryption**:
   - Use the test file `test_input.txt` to verify the program's operation. The file contains the text "This is a test file for encryption and decryption."
   - Run the program and select file encryption using AES, then encrypt the session key with RSA.
   - After encryption, check the encrypted text file, then perform decryption to verify the program's correctness.
   - Compare the input and output files to ensure they are identical.
   - You can also use the `make test` command to automatically run tests that verify all main functions of the program.

**Test Results**

A test was conducted on the encryption and decryption of the file `test_input.txt`, which contains the text "This is a test file for encryption and decryption." The test confirmed the correct operation of both symmetric and asymmetric encryption. The file was successfully encrypted, and upon decryption, the text was restored to its original form.

**Conclusions**

During the lab work, I became familiar with the OpenSSL library and its capabilities for symmetric and asymmetric encryption. Implementing the AES and RSA algorithms in a C application showed that they can be used to ensure data security in modern systems.

