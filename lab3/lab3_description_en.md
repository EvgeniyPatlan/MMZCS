### Algorithm Description

#### 1. Session Key Generation
The algorithm begins by generating a **session key** using the **Lehmer RNG (Lehmer Random Number Generator)**, which is a type of linear congruential generator for random numbers. The session key is generated based on an initial value (seed), a multiplier, and a modulus. The resulting value is used as the session key, whose length is determined by the parameter `2w`, where `w` is the bit length of the data block.

The session key is stored in the file `s_key.txt` and will be used later for encrypting data during the communication session.

#### 2. Control Vector Generation
Following the session key generation, a **control vector** is generated. This vector controls the usage parameters of the session key. Like the session key, the control vector is generated using the **Lehmer RNG**, but with a different initial value (seed) and a modulus determined by the parameter `5N` (where `N` is the bit length of the session key).

The control vector provides additional security by defining limitations on the usage of the session key and ensuring that it is tied to specific usage parameters.

#### 3. Control Vector Hashing using RXOR
The control vector is then hashed using the **RXOR (Recursive XOR)** algorithm. RXOR is a simple hashing function that applies the XOR operation to all bytes of the control vector. Each character of the control vector is converted to its ASCII representation, and the XOR operation is applied to all these values, resulting in the **hash of the control vector**.

This hash is an important step in generating the encryption key, as it will be combined with the master key entered by the user.

#### 4. User Input of Master Key
The user is prompted to input a **master key**, which must be a binary string (composed of 0s and 1s). The master key is entered through the console, and it is validated to ensure that it only contains binary values (0s and 1s). The master key length is defined by the parameter `N`, which typically ranges from 16 bits or more, depending on the required key size.

The master key acts as the primary encryption key and ensures the security of the session key when encrypting it for transmission between parties.

#### 5. Encryption Key Calculation
To encrypt the session key, an **XOR** operation is applied between the master key entered by the user and the hashed control vector. This creates an **encryption key**, which is uniquely derived from both the master key and the control vector.

This approach ensures that the encrypted session key cannot be recovered without knowledge of both the master key and the control vector.

#### 6. Encryption of the Session Key
The session key, which has been saved in the file `s_key.txt`, is encrypted using the encryption key obtained from the XOR of the master key and the hashed control vector. The XOR operation is applied between each byte of the session key and the corresponding byte of the encryption key.

This encryption process guarantees that even if the encrypted session key is intercepted, it cannot be decrypted without the correct master key and control vector.

#### 7. Saving the Encrypted Session Key
The encrypted session key is saved in the file `m_key.txt`. This key will be transmitted between parties. Once the recipient receives the encrypted session key, they can decrypt it using their master key and the control vector, thereby recovering the original session key for secure communication.

#### 8. Output of Results
After the session key is successfully encrypted, the following results are displayed to the user:
- The **original session key** in its unencrypted form.
- The **encrypted session key**, which is saved to the file `m_key.txt`.

This confirms the successful execution of the encryption process and the readiness of the session key for transmission.

### Overall Summary
The algorithm securely generates and encrypts session keys using symmetric encryption and hashing techniques. The session keys are generated using a simple Lehmer RNG, and the encryption process relies on the XOR operation. The control vector and the RXOR hashing algorithm provide an additional layer of security. By tying the session key to both the master key and the control vector, the algorithm ensures that the encrypted session key is protected and can only be decrypted by authorized parties.
