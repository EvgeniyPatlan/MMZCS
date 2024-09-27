# Compiler
CXX = g++

# Compiler Flags
CXXFLAGS = -Wall -Wextra -pedantic -std=c++11 -I/usr/include/gtest -I/usr/include/openssl

# OpenSSL and GoogleTest Libraries
LIBS = -lssl -lcrypto -lgtest -lgtest_main -lpthread

# Executable Names
TARGET = aes_crypto_app
TEST_TARGET = test_app

# Source Files
SRCS = main.cpp crypto.cpp
TEST_SRCS = test.cpp crypto.cpp

# Object Files
OBJS = $(SRCS:.cpp=.o)
TEST_OBJS = $(TEST_SRCS:.cpp=.o)

# Default Target
all: $(TARGET)

# Compile and Link the Main Target (aes_crypto_app)
$(TARGET): $(OBJS)
	$(CXX) $(CXXFLAGS) -o $(TARGET) $(OBJS) $(LIBS)

# Compile and Link the Test Target (test_app)
test: $(TEST_TARGET)

$(TEST_TARGET): $(TEST_OBJS)
	$(CXX) $(CXXFLAGS) -o $(TEST_TARGET) $(TEST_OBJS) $(LIBS)

# Compile Source Files into Object Files
%.o: %.cpp
	$(CXX) $(CXXFLAGS) -c $< -o $@

# Clean up object files and executables
clean:
	rm -f $(OBJS) $(TEST_OBJS) $(TARGET) $(TEST_TARGET)

# Install dependencies (GCC, G++, OpenSSL, GoogleTest, CMake)
install_deps:
	sudo apt-get update && sudo apt-get install -y build-essential gcc g++ libssl-dev libgtest-dev cmake && \
	cd /usr/src/gtest && sudo cmake CMakeLists.txt && sudo make && sudo cp *.a /usr/lib

# Run the Main Program
run: $(TARGET)
	./$(TARGET)

# Run the Tests
run_tests: test
	./$(TEST_TARGET)

.PHONY: clean all run install_deps test run_tests

roo
