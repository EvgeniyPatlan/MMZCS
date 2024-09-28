CC = gcc
CFLAGS = -Wall -g
LIBS = -lssl -lcrypto

# Default target to build both server and client
all: tls_server tls_client

# Target for the server executable
tls_server: tls_server_minimal.c
	$(CC) $(CFLAGS) tls_server_minimal.c -o tls_server $(LIBS)

# Target for the client executable
tls_client: tls_client_minimal.c
	$(CC) $(CFLAGS) tls_client_minimal.c -o tls_client $(LIBS)

# Generate certificates for the server
certs:
	bash ./generate_certs.sh

# Clean up the build and generated certificates/keys
clean:
	rm -f tls_server tls_client server.log client.log serv_cert.pem serv_key.pem

# Clean up only the generated certificates/keys
clean_certs:
	rm -f serv_cert.pem serv_key.pem

# Full clean (binaries + certificates/keys)
clean_all: clean clean_certs

# Install necessary dependencies
install_deps:
	sudo apt-get update
	sudo apt-get install -y libssl-dev gcc

