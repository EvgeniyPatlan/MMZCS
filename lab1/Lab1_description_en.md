
### Detailed Step-by-Step Breakdown of the `lab1.pl` Script and LFSR Algorithm

The `lab1.pl` script uses a **Linear Feedback Shift Register (LFSR)** to implement stream encryption. Here's a complete breakdown:

### 1. **Reading Command-Line Arguments**
   The user provides the following parameters:
   - `--input`: The input file to encrypt.
   - `--encrypted`: The file to store the encrypted data.
   - `--decrypted`: The file to store the decrypted data.
   - `--polynomial`: The polynomial (as a decimal number) used for feedback in the LFSR.
   - `--init_value`: The initial value to seed the LFSR.
   - `--size`: The size of the LFSR (number of bits, up to 64).

### 2. **Initializing the LFSR**
   The LFSR is a binary sequence where each bit is shifted to the right, and feedback is applied to generate a new bit, which is added to the leftmost (most significant) bit.
   
   #### Polynomial and Initial State:
   - **Polynomial**: The polynomial defines which bits in the shift register participate in the XOR feedback. For example, polynomial 285 in binary (`100011101`).
   - **Initial State**: The initial state is a seed provided by the user, e.g., `12345` in binary (`11000000111001`).
   
   #### Shift Process:
   At each step:
   - The least significant bit (LSB) of the register is used as the next key bit.
   - All other bits shift to the right.
   - The feedback bit is computed by XORing specific bits defined by the polynomial.
   - The feedback bit is placed in the most significant bit (MSB).
   
   #### Example of Shifting:
   Let's assume the initial state is `11000000111001` (12345), and the polynomial is 285 (`100011101`).
   
   **Step 1**:
   - Take the LSB: `1` (key bit).
   - Shift right: `01100000011100`.
   - XOR the bits defined by the polynomial (bits 1, 3, 6, and 9). The XOR result is `1`.
   - New state: `11100000011100`.
   
   **Step 2**:
   - Take the LSB: `0` (key bit).
   - Shift right: `01110000001110`.
   - XOR the bits: result is `0`.
   - New state: `00111000001110`.

   This process repeats until the required number of bits is generated (equal to the length of the input file in bits).

### 3. **Key Stream Generation**
   Once the LFSR is initialized, it generates a pseudo-random key stream. The number of bits in the key stream should match the number of bits in the input file (file size in bytes * 8).

   #### Example:
   For a 3-byte (24-bit) file, the key stream also needs 24 bits, e.g., `110000101011000010111101`.

### 4. **Encryption/Decryption (XOR) Operation**
   For each byte in the input file, the script performs a bitwise **XOR** operation between the byte and the corresponding bits of the key stream.
   
   #### Encryption Example:
   Suppose the input byte is `11101101` (237), and the corresponding key stream bits are `10001111`.
   - **First bit**: XOR between `1` (input) and `1` (key) gives `0`.
   - **Second bit**: XOR between `1` (input) and `0` (key) gives `1`.
   - And so on for each bit:
     - XOR result: `01100010` (98).
   - The encrypted byte is `01100010` (98).

   The decryption process is the same as encryption, since XOR with the same key returns the original value.

### 5. **Writing the Encrypted/Decrypted Files**
   After the XOR operation, the script writes the results into the corresponding files:
   - **Encrypted file**: Stores the encrypted data.
   - **Decrypted file**: Stores the decrypted data.

### 6. **File Comparison**
   After decryption, the script compares the original input file and the decrypted file byte by byte.
   - If all bytes match, encryption and decryption were successful.
   - If there is any difference, it indicates an error in the encryption/decryption process.

### 7. **Logging**
   Each encryption and decryption operation is logged in detail:
   - **LFSR Initialization**: The initial state and polynomial used.
   - **LFSR Shifting**: For each step, the new state of the register and the key bit are logged.
   - **XOR Operations**: For each byte, the original byte, the key bits, and the XOR result are logged.
   - **File Comparison**: The result of comparing the original and decrypted files is logged.

### Example of the LFSR Algorithm in Detail:

1. **Polynomial**: 285 (`100011101` in binary).
2. **Initial State**: 12345 (`11000000111001` in binary).
3. **Shift Steps**:
   
   **Step 1**:
   - Initial state: `11000000111001`.
   - LSB = `1` (key bit).
   - Right shift: `01100000011100`.
   - XOR of bits defined by the polynomial = `1`.
   - New state: `11100000011100`.

   **Step 2**:
   - Initial state: `11100000011100`.
   - LSB = `0` (key bit).
   - Right shift: `01110000001110`.
   - XOR result = `0`.
   - New state: `00111000001110`.

   This process continues until the key stream matches the length of the input file in bits.

### Conclusion:
The script uses LFSR to generate a pseudo-random key stream for stream encryption. The XOR operation between the input file bytes and the key stream encrypts and decrypts the data. After decryption, the original and decrypted files are compared to ensure the process worked correctly.
