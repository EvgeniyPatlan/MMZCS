**Lab Work No. 6: Certificate Generation and Validation Using OpenSSL**

**Objective:** Learn how to generate certificates using OpenSSL, including a CA certificate and user certificates, and verify them using Bash scripts.

**Theoretical Background**

This lab focuses on using OpenSSL to generate and validate certificates. Certificates are an essential part of secure communication, used to authenticate parties and establish trust in cryptographic exchanges.

**Certificates and OpenSSL**  
- **CA Certificate**: The certificate authority (CA) issues digital certificates, serving as a trusted entity.  
- **User Certificates**: Certificates for individuals (User A, User B) are signed by the CA to verify authenticity.

**Implementation Description**

The lab includes two Bash scripts (`generate_certs.sh` and `test_script.sh`) that perform the following:

1. **Certificate Generation**:
   - Generate CA and user certificates with `generate_certs.sh`.
   - The script creates keys for the CA, User A, and User B, and signs their certificates using the CA key.

2. **Testing and Verification**:
   - Run `test_script.sh` to verify that all certificates are correctly generated and valid.
   - Validate the CA certificate, as well as User A and User B certificates, to ensure they meet security requirements.

**How the Program Works**

1. **Generating Certificates**:
   - Run `./generate_certs.sh` to generate CA and user certificates.
   - The script first checks for OpenSSL installation, then generates the CA’s self-signed certificate.
   - User A and User B key pairs are generated, followed by signing their certificates using the CA.

2. **Verifying Certificates**:
   - Execute `./test_script.sh` to verify the certificates.
   - The script checks that each key and certificate is correctly generated and validates their authenticity using OpenSSL commands.

**How to Build and Run the Program**

1. **Generating Certificates**:
   - Ensure OpenSSL is installed (`sudo apt-get install openssl`).
   - Run `./generate_certs.sh` to generate:
     - A CA key and certificate.
     - User A and User B key pairs and certificates.
     - Exported PKCS#12 formatted certificates for User A and User B.
   
2. **Running Tests**:
   - Run `./test_script.sh` to verify the generated certificates.
   - The script checks for the presence of the CA, User A, and User B certificates, and verifies their validity.

**Running Tests**

1. **Testing Certificate Generation**:
   - Run `./generate_certs.sh` to generate certificates for the CA and users.
   - Verify the presence of the expected certificate files (`ca_cert.pem`, `userA_cert.p12`, `userB_cert.p12`).

2. **Testing with `test_script.sh`**:
   - Execute `./test_script.sh` to validate:
     - The successful generation of all required certificates.
     - The validity of the CA, User A, and User B certificates using OpenSSL commands.

**Test Results**

The test was conducted using `test_script.sh` to validate the generated certificates. All required certificates (CA, User A, User B) were generated successfully and validated without errors, confirming their authenticity and correctness.

**Conclusions**

This lab provided hands-on experience with OpenSSL for generating and managing certificates. We learned how to create a CA certificate and use it to sign user certificates, followed by their validation. This process is crucial for secure communications, and it shows how to establish a trusted public key infrastructure (PKI) using OpenSSL tools and scripting in Bash.

