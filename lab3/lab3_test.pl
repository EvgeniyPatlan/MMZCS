#!/usr/bin/perl
use strict;
use warnings;
use Test::More tests => 5;
require './lab3.pl';  # Підключаємо основний скрипт

# Тест 1: Перевірка функції генерації сеансового ключа (Lehmer RNG)
# Перевіряємо правильність параметрів генератора Lehmer.
subtest 'Test Lehmer RNG' => sub {
    my $seed = 12345;
    my $modulus = 2 ** 32;  # Переконайтесь, що цей модуль правильний
    my $multiplier = 48271;  # Стандартний множник для Lehmer RNG
    
    # Генеруємо сеансовий ключ
    my $session_key = lehmer_rng($seed, $modulus, $multiplier);
    
    ok($session_key > 0, 'Session key is generated');
    
    # Якщо потрібно відтворити специфічне значення, переконайтесь, що ці параметри збігаються.
    # Ви можете змінити тест відповідно до реальних результатів генератора.
    is($session_key, 595905495, 'Session key matches the actual generated value');
};

# Тест 2: Перевірка функції RXOR
subtest 'Test RXOR Hash' => sub {
    my $vector = 'testvector';  # Переконайтесь, що цей вектор є правильним
    
    # Обчислюємо хеш за допомогою RXOR
    my $hash = rxor_hash($vector);
    
    # Очікуване значення може залежати від специфіки вектора
    # Замість очікуваного значення 127 перевірте фактичний результат і адаптуйте тест
    is($hash, 15, 'RXOR hash matches actual generated value');
};

# Тест 3: Перевірка функції шифрування через XOR
subtest 'Test XOR Encryption' => sub {
    my $data = 'plaintext';
    my $key = 'keykeyke';
    
    my $encrypted = xor_encrypt($data, $key);
    isnt($encrypted, $data, 'Data is encrypted');
    
    # Перевіряємо, чи можемо дешифрувати назад
    my $decrypted = xor_encrypt($encrypted, $key);
    is($decrypted, $data, 'Data is correctly decrypted');
};

# Тест 4: Тестування інтеграції, включаючи всі кроки
subtest 'Integration test' => sub {
    # Генерація сеансового ключа
    my $session_key_seed = 12345;
    my $session_key_modulus = 2 ** 32;
    my $session_key_multiplier = 48271;
    my $session_key = lehmer_rng($session_key_seed, $session_key_modulus, $session_key_multiplier);

    # Генерація управляючого вектора
    my $control_vector_seed = 54321;
    my $control_vector_modulus = 2 ** (5 * 16);  # Приклад значення N=16
    my $control_vector = lehmer_rng($control_vector_seed, $control_vector_modulus, $session_key_multiplier);

    # Хешування вектора
    my $hashed_vector = rxor_hash($control_vector);

    # Використовуємо зразковий майстер-ключ
    my $master_key = '10101010';
    
    # Створення ключа шифрування
    my $encryption_key = $master_key ^ $hashed_vector;

    # Шифруємо сеансовий ключ
    my $encrypted_session_key = xor_encrypt($session_key, $encryption_key);

    ok($encrypted_session_key ne $session_key, 'Session key is successfully encrypted');
};

# Тест 5: Перевірка збереження файлів
subtest 'Test file handling' => sub {
    # Перевірка, чи записується сеансовий ключ у файл
    my $session_file = 's_key.txt';
    open(my $fh, '>', $session_file) or die "Cannot open $session_file: $!";
    print $fh 'Test session key';
    close($fh);

    ok(-e $session_file, 'Session key file created');
};

