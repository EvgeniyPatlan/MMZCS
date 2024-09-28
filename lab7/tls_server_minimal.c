#include <openssl/ssl.h>
#include <openssl/err.h>
#include <netdb.h>
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

    method = TLS_server_method();  // Use modern TLS method
    ctx = SSL_CTX_new(method);
    if (!ctx) {
        perror("Unable to create SSL context");
        ERR_print_errors_fp(stderr);
        exit(EXIT_FAILURE);
    }

    return ctx;
}

void configure_context(SSL_CTX *ctx) {
    SSL_CTX_use_certificate_file(ctx, "serv_cert.pem", SSL_FILETYPE_PEM);  // Use server certificate
    SSL_CTX_use_PrivateKey_file(ctx, "serv_key.pem", SSL_FILETYPE_PEM);  // Use private key

    // Ensure the private key matches the certificate
    if (!SSL_CTX_check_private_key(ctx)) {
        fprintf(stderr, "Private key does not match the public certificate\n");
        exit(EXIT_FAILURE);
    }
}

int main() {
    int sockfd, newsockfd;
    struct sockaddr_in addr;
    socklen_t len = sizeof(addr);
    SSL_CTX *ctx;

    init_openssl();
    ctx = create_context();
    configure_context(ctx);

    sockfd = socket(AF_INET, SOCK_STREAM, 0);
    addr.sin_family = AF_INET;
    addr.sin_port = htons(PORT);
    addr.sin_addr.s_addr = htonl(INADDR_ANY);

    bind(sockfd, (struct sockaddr*)&addr, sizeof(addr));
    listen(sockfd, 1);

    newsockfd = accept(sockfd, (struct sockaddr*)&addr, &len);

    SSL *ssl = SSL_new(ctx);
    SSL_set_fd(ssl, newsockfd);

    if (SSL_accept(ssl) <= 0) {
        ERR_print_errors_fp(stderr);
    } else {
        char buffer[1024] = {0};
        SSL_read(ssl, buffer, sizeof(buffer));
        printf("Received: %s\n", buffer);
        SSL_write(ssl, buffer, strlen(buffer));
    }

    SSL_free(ssl);
    close(newsockfd);
    close(sockfd);
    SSL_CTX_free(ctx);
    cleanup_openssl();
}

