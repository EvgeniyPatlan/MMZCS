#include <openssl/ssl.h>
#include <openssl/err.h>
#include <arpa/inet.h>
#include <unistd.h>

#define PORT 8080

void init_openssl() {
    SSL_load_error_strings();
    OpenSSL_add_ssl_algorithms();
}

void cleanup_openssl() {
    EVP_cleanup();
}

SSL_CTX *create_context() {
    const SSL_METHOD *method;
    SSL_CTX *ctx;

    method = TLS_client_method();  // Use modern TLS method
    ctx = SSL_CTX_new(method);
    if (!ctx) {
        perror("Unable to create SSL context");
        ERR_print_errors_fp(stderr);
        exit(EXIT_FAILURE);
    }

    return ctx;
}

int main() {
    struct sockaddr_in addr;
    int sockfd;
    SSL_CTX *ctx;
    SSL *ssl;

    init_openssl();
    ctx = create_context();

    sockfd = socket(AF_INET, SOCK_STREAM, 0);
    addr.sin_family = AF_INET;
    addr.sin_port = htons(PORT);
    inet_pton(AF_INET, "127.0.0.1", &addr.sin_addr);

    connect(sockfd, (struct sockaddr*)&addr, sizeof(addr));

    ssl = SSL_new(ctx);
    SSL_set_fd(ssl, sockfd);

    if (SSL_connect(ssl) <= 0) {
        ERR_print_errors_fp(stderr);
    } else {
        const char *msg = "Hello from client!";
        SSL_write(ssl, msg, strlen(msg));

        char buffer[1024] = {0};
        SSL_read(ssl, buffer, sizeof(buffer));
        printf("Received: %s\n", buffer);
    }

    SSL_free(ssl);
    close(sockfd);
    SSL_CTX_free(ctx);
    cleanup_openssl();
}

