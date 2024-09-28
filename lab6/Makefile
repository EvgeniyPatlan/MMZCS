# Compiler and flags
CXX = g++
CXXFLAGS = -std=c++14 -Wall -g
LDFLAGS = -lssl -lcrypto -lgtest -lpthread
INCLUDES = -I.

# File paths for source and test files
SRC = main.cpp
CRYPTO_SRC = crypto_functions.cpp
TEST_SRC = test/test_main.cpp

# Paths for certificates
CERT_DIR = certs
USER_CERT = $(CERT_DIR)/userA_cert.pem
USER_KEY = $(CERT_DIR)/userA_key.pem

# Targets for the main program and tests
TARGET = crypto_app
TEST_TARGET = run_tests

# Help message
help:
	@echo "Usage:"
	@echo "  make            - Build the main application and tests"
	@echo "  make test       - Run the tests"
	@echo "  make clean      - Clean up build files"
	@echo "  make certs      - Run the certificate generation script"
	@echo "  make full_test  - Generate certificates, build the app, and run the tests"

# Default rule to build everything
all: $(TARGET) $(TEST_TARGET)

# Build the main application
$(TARGET): $(SRC) $(CRYPTO_SRC)
	$(CXX) $(CXXFLAGS) $(INCLUDES) -o $(TARGET) $(SRC) $(CRYPTO_SRC) $(LDFLAGS)

# Build the test application
$(TEST_TARGET): $(TEST_SRC) $(CRYPTO_SRC)
	$(CXX) $(CXXFLAGS) $(INCLUDES) -o $(TEST_TARGET) $(TEST_SRC) $(CRYPTO_SRC) $(LDFLAGS)

# Run tests using Google Test
test: $(TEST_TARGET)
	./$(TEST_TARGET)

# Clean the build artifacts and the certificates directory
clean:
	rm -f $(TARGET) $(TEST_TARGET) *.o
	rm -rf test_message.txt test_encrypted.txt test_decrypted.txt
	rm -rf $(CERT_DIR)

# Run the certificate generation script
certs:
	./generate_certs.sh

# Full test pipeline: generate certificates, build, and run tests
full_test: certs all test
