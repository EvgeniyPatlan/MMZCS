CC = gcc
CFLAGS = -Wall -I/usr/include/openssl -I/usr/include/CUnit
LDFLAGS = -lssl -lcrypto -lcunit

TARGET = crypto
TEST_TARGET = test_crypto

SRC = crypto.c
TEST_SRC = test_crypto.c

OBJ = $(SRC:.c=.o)
TEST_OBJ = $(TEST_SRC:.c=.o)

$(TARGET): $(OBJ)
	$(CC) $(OBJ) -o $(TARGET) $(LDFLAGS)

$(TEST_TARGET): $(TEST_OBJ) $(OBJ)
	$(CC) $(TEST_OBJ) $(OBJ) -o $(TEST_TARGET) $(LDFLAGS)

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

test: CFLAGS += -DTEST_MODE
test: $(TEST_TARGET)
	./$(TEST_TARGET)

debug: CFLAGS += -DTEST_MODE
debug: $(TEST_TARGET)
	gdb ./$(TEST_TARGET)

install_deps:
	@echo "Installing required dependencies..."
	@sudo apt-get update
	@sudo apt-get install -y libssl-dev libcrypto++-dev libcunit1-dev

clean:
	rm -f $(OBJ) $(TEST_OBJ) $(TARGET) $(TEST_TARGET)

.PHONY: clean test install_deps debug
