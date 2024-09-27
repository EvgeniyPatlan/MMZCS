use strict;
use warnings;
use Test::More tests => 9;  # Кількість тестів
use File::Slurp;            # Для читання/запису файлів

# Шляхи до основного скрипта і файлів
my $script = './lab2.pl';  # Вкажіть правильний шлях до вашого скрипта
my $input_file = 'test_input.txt';
my $output_file_enc = 'test_output.enc';
my $output_file_dec = 'test_output.dec';

# Тестові дані
my $test_data = "Hello, this is a test!";
my $key = "1234567890abcdef1234567890abcdef";
my $iv = "abcdef1234567890";

# Записуємо тестові дані у вхідний файл
write_file($input_file, $test_data);

# 1. Тест режиму ECB (шифрування та дешифрування)
sub test_ecb_mode {
    my $cipher_mode = 1;  # ECB mode
    my $mode_encrypt = 1; # Шифрування
    my $mode_decrypt = 2; # Дешифрування

    # Виконуємо шифрування
    system("perl $script --input $input_file --output $output_file_enc --key $key --mode $mode_encrypt --cipher $cipher_mode");

    # Перевіряємо, чи був створений файл зашифрованих даних
    ok(-e $output_file_enc, 'ECB mode: Encryption file exists');

    # Виконуємо дешифрування
    system("perl $script --input $output_file_enc --output $output_file_dec --key $key --mode $mode_decrypt --cipher $cipher_mode");

    # Перевіряємо, чи був створений файл розшифрованих даних
    ok(-e $output_file_dec, 'ECB mode: Decryption file exists');

    # Читаємо результати розшифрування і порівнюємо з початковими даними
    my $decrypted_data = read_file($output_file_dec);
    is($decrypted_data, $test_data, 'ECB mode: Decrypted data matches original');
}

# 2. Тест режиму CTR (шифрування та дешифрування)
sub test_ctr_mode {
    my $cipher_mode = 2;  # CTR mode
    my $mode_encrypt = 1; # Шифрування
    my $mode_decrypt = 2; # Дешифрування

    # Виконуємо шифрування
    system("perl $script --input $input_file --output $output_file_enc --key $key --iv $iv --mode $mode_encrypt --cipher $cipher_mode");

    # Перевіряємо, чи був створений файл зашифрованих даних
    ok(-e $output_file_enc, 'CTR mode: Encryption file exists');

    # Виконуємо дешифрування
    system("perl $script --input $output_file_enc --output $output_file_dec --key $key --iv $iv --mode $mode_decrypt --cipher $cipher_mode");

    # Перевіряємо, чи був створений файл розшифрованих даних
    ok(-e $output_file_dec, 'CTR mode: Decryption file exists');

    # Читаємо результати розшифрування і порівнюємо з початковими даними
    my $decrypted_data = read_file($output_file_dec);
    is($decrypted_data, $test_data, 'CTR mode: Decrypted data matches original');
}

# 3. Тест режиму CFB (шифрування та дешифрування)
sub test_cfb_mode {
    my $cipher_mode = 3;  # CFB mode
    my $mode_encrypt = 1; # Шифрування
    my $mode_decrypt = 2; # Дешифрування

    # Виконуємо шифрування
    system("perl $script --input $input_file --output $output_file_enc --key $key --iv $iv --mode $mode_encrypt --cipher $cipher_mode");

    # Перевіряємо, чи був створений файл зашифрованих даних
    ok(-e $output_file_enc, 'CFB mode: Encryption file exists');

    # Виконуємо дешифрування
    system("perl $script --input $output_file_enc --output $output_file_dec --key $key --iv $iv --mode $mode_decrypt --cipher $cipher_mode");

    # Перевіряємо, чи був створений файл розшифрованих даних
    ok(-e $output_file_dec, 'CFB mode: Decryption file exists');

    # Читаємо результати розшифрування і порівнюємо з початковими даними
    my $decrypted_data = read_file($output_file_dec);
    is($decrypted_data, $test_data, 'CFB mode: Decrypted data matches original');
}

# Виконання тестів
test_ecb_mode();
test_ctr_mode();
test_cfb_mode();

# Видаляємо тимчасові файли після тестів
unlink $input_file, $output_file_enc, $output_file_dec;
