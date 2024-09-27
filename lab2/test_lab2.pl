use strict;
use warnings;
use lib '.';  # Вказує на поточну директорію
use Test::More tests => 6;
use GOST_Encryption;

# Тестові дані
my $key = pack("H*", "0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF");
my $iv = pack("H*", "1234567890ABCDEF");
my $plain_text = "TestText";
my $keys = GOST_Encryption::generate_keys($key);

# Тест 1: Шифрування в режимі ECB
my $cipher_text_ecb = GOST_Encryption::ecb_mode($plain_text, $keys, 'encrypt');
ok($cipher_text_ecb ne $plain_text, 'ECB encryption works');

# Тест 2: Дешифрування в режимі ECB
my $decrypted_text_ecb = GOST_Encryption::ecb_mode($cipher_text_ecb, $keys, 'decrypt');
is($decrypted_text_ecb, $plain_text, 'ECB decryption works');

# Тест 3: Шифрування в режимі OFB
my $cipher_text_ofb = GOST_Encryption::ofb_mode($plain_text, $keys, $iv, 'encrypt');
ok($cipher_text_ofb ne $plain_text, 'OFB encryption works');

# Тест 4: Дешифрування в режимі OFB
my $decrypted_text_ofb = GOST_Encryption::ofb_mode($cipher_text_ofb, $keys, $iv, 'decrypt');
is($decrypted_text_ofb, $plain_text, 'OFB decryption works');

# Тест 5: Шифрування в режимі CFB
my $cipher_text_cfb = GOST_Encryption::cfb_mode($plain_text, $keys, $iv, 'encrypt');
ok($cipher_text_cfb ne $plain_text, 'CFB encryption works');

# Тест 6: Дешифрування в режимі CFB
my $decrypted_text_cfb = GOST_Encryption::cfb_mode($cipher_text_cfb, $keys, $iv, 'decrypt');
is($decrypted_text_cfb, $plain_text, 'CFB decryption works');

