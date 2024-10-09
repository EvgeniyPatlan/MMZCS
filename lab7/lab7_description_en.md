**Lab Work No. 7: Secure Data Transmission Using TLS with OpenSSL**

**Objective:** Learn how to establish secure TLS connections using OpenSSL and gain skills in creating simple client and server applications in a Linux environment.

**Theoretical Background**

The TLS (Transport Layer Security) protocol is a modern standard for ensuring data transmission security. TLS provides data encryption, authentication of the parties, and message integrity, making it essential for protecting sensitive information. In this lab, a TLS connection with server-side authentication is implemented.

**Certificates and OpenSSL**  
- **CA Certificate**: The Certificate Authority (CA) generates and signs certificates that act as proof of authenticity.  
- **User Certificates**: Certificates signed by the CA are used to establish TLS connections, ensuring the authenticity of the participants in data exchange.

**Implementation Description**

1. **Certificate Generation**:
   - An RSA key pair (2048 bits) and a self-signed certificate for the CA were generated using OpenSSL.
   - Two key pairs were generated for users (client and server), whose certificates were signed by the CA and stored in PKCS#12 format.
   - The script `generate_certs.sh` generates the necessary certificates for the server and users.

2. **Development of Client and Server Applications**:
   - Console applications in C were developed using OpenSSL to establish TLS connections.
   - **Server Application (`tls_server_minimal.c`)**: Creates a TLS context, listens for incoming connections via a TCP socket, accepts the client connection, and establishes a TLS session for secure data transmission.
   - **Client Application (`tls_client_minimal.c`)**: Creates a TLS context, connects to the server over TLS, and sends a message.

**How the Program Works**

1. **Certificate Generation**:
   - Execute the script `generate_certs.sh` to create the necessary certificates (CA, client, server).
   - RSA keys are generated for the server and users, and then signed by the CA.
   - Certificates are also stored in PKCS#12 format using the script `generate_pkcs12.sh`.

2. **Setting Up the Environment**:
   - Ensure the necessary libraries for OpenSSL (`libssl-dev`) and the GCC compiler are installed.
   - The OpenSSL library is initialized using `SSL_library_init()`, and the TLS context is set up using `SSL_CTX_new()` and `SSL_CTX_set_mode()`.

3. **Establishing a TLS Connection**:
   - **Server Application**: Creates a TLS context, sets the certificate and private key, listens for incoming connections using a TCP socket, and initiates a TLS connection after accepting the client.
   - **Client Application**: Creates a TLS context, sets the trusted CA certificate, connects to the server, and initiates a TLS handshake to establish a secure connection.

4. **Message Exchange**:
   - After a successful TLS handshake, the client sends a text message to the server, which the server returns to confirm receipt.
   - Messages are exchanged using the functions `SSL_write()` and `SSL_read()`.

5. **Connection Termination**:
   - After data exchange, the TLS connection is closed using `SSL_shutdown()`, followed by closing the TCP connection and releasing resources.

**How to Build and Run the Program**

1. **Certificate Generation**:
   - Ensure OpenSSL is installed (`sudo apt-get install openssl`).
   - Run the script `generate_certs.sh` to generate the required certificates (CA, client, server).

2. **Building the Program**:
   - Use GCC to compile the server and client applications:
     ```
     gcc -o tls_server tls_server_minimal.c -lssl -lcrypto
     gcc -o tls_client tls_client_minimal.c -lssl -lcrypto
     ```

3. **Running the Program**:
   - First, run the server application, which listens on the specified port:
     ```
     ./tls_server
     ```
   - Then, run the client application and provide the server's IP address to establish the connection:
     ```
     ./tls_client
     ```

**Running Tests**

1. **Testing Certificate Generation**:
   - Run `./generate_certs.sh` to generate certificates for the CA and users.
   - Verify the existence of the expected certificate files (`serv_cert.pem`, `user1_cert.pem`, `user2_cert.pem`).

2. **Running the Test Script (`run_tests.sh`)**:
   - The script first generates certificates, starts the server application in the background, then starts the client application, and compares the output to the expected result.
   - Expected result: `"Received: Hello from client!"`.

**Test Results**

A test was conducted to establish a TLS connection between the client and server. The client successfully connected to the server, sent a text message, which the server returned for confirmation. The TLS connection was successfully established, and the message was transmitted without errors.

**Conclusions**

This lab provided an introduction to the TLS protocol and its implementation using OpenSSL. Certificates were created to ensure authentication, and applications were developed to establish secure connections. The implementation of the client-server model demonstrated how to secure data transmission in networks using TLS and OpenSSL.

