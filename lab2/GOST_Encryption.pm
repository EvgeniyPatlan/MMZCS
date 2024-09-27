package GOST_Encryption;

use strict;
use warnings;

# Таблиця замін (S-блоки)
my @S_BOX = (
    [4, 10, 9, 2, 14, 1, 7, 15, 6, 8, 0, 13, 3, 11, 5, 12],
    [12, 4, 6, 2, 10, 5, 11, 9, 14, 8, 13, 15, 3, 7, 1, 0],
    [11, 12, 4, 7, 9, 5, 0, 6, 10, 2, 14, 1, 3, 8, 15, 13],
    [4, 11, 10, 12, 0, 7, 2, 1, 13, 3, 6, 8, 5, 9, 15, 14],
    [6, 8, 2, 3, 9, 10, 5, 12, 1, 14, 4, 7, 11, 13, 0, 15],
    [12, 9, 11, 1, 8, 14, 2, 4, 7, 6, 10, 0, 5, 3, 15, 13],
    [14, 8, 11, 5, 12, 2, 3, 9, 7, 13, 0, 4, 10, 1, 6, 15],
    [15, 12, 2, 10, 4, 13, 1, 7, 5, 0, 15, 11, 9, 3, 14, 6]
);

# Функція раунду
sub feistel_function {
    my ($half_block, $round_key) = @_;
    
    my $result = ($half_block + $round_key) % (2**32);
    my @nibbles = map { ($result >> (4 * $_)) & 0xF } reverse (0..7);
    for my $i (0..7) {
        $nibbles[$i] = $S_BOX[$i][$nibbles[$i]];
    }
    $result = 0;
    for my $i (0..7) {
        $result |= ($nibbles[$i] << (4 * (7 - $i)));
    }
    $result = (($result << 11) | ($result >> (32 - 11))) & 0xFFFFFFFF;
    return $result;
}

# Основна функція шифрування блоку
sub encrypt_block {
    my ($block, $keys) = @_;
    my ($left, $right) = unpack("N2", $block);
    for my $i (0..31) {
        my $temp = $right;
        $right = $left ^ feistel_function($right, $keys->[$i % 8]);
        $left = $temp;
    }
    return pack("N2", $right, $left);
}

# Функція дешифрування блоку
sub decrypt_block {
    my ($block, $keys) = @_;
    my ($left, $right) = unpack("N2", $block);
    for my $i (reverse 0..31) {
        my $temp = $right;
        $right = $left ^ feistel_function($right, $keys->[$i % 8]);
        $left = $temp;
    }
    return pack("N2", $right, $left);
}

# Режим простої заміни (ECB)
sub ecb_mode {
    my ($data, $keys, $operation) = @_;
    my $result = '';
    while (length($data) >= 8) {
        my $block = substr($data, 0, 8, '');
        if ($operation eq 'encrypt') {
            $result .= encrypt_block($block, $keys);
        } else {
            $result .= decrypt_block($block, $keys);
        }
    }
    if (length($data)) {
        my $block = $data . ("\x00" x (8 - length($data)));
        if ($operation eq 'encrypt') {
            $result .= encrypt_block($block, $keys);
        } else {
            $result .= decrypt_block($block, $keys);
        }
    }
    return $result;
}

# Режим гамування (OFB)
sub ofb_mode {
    my ($data, $keys, $iv, $operation) = @_;
    my $result = '';
    my $gamma = $iv;
    while (length($data) >= 8) {
        my $block = substr($data, 0, 8, '');
        $gamma = encrypt_block($gamma, $keys);
        $result .= $gamma ^ $block;
    }
    return $result;
}

# Режим гамування зі зворотним зв'язком (CFB)
sub cfb_mode {
    my ($data, $keys, $iv, $operation) = @_;
    my $result = '';
    my $feedback = $iv;
    while (length($data) >= 8) {
        my $block = substr($data, 0, 8, '');
        $feedback = encrypt_block($feedback, $keys);
        if ($operation eq 'encrypt') {
            my $cipher_block = $feedback ^ $block;
            $result .= $cipher_block;
            $feedback = $cipher_block;
        } elsif ($operation eq 'decrypt') {
            my $plain_block = $feedback ^ $block;
            $result .= $plain_block;
            $feedback = $block;
        }
    }
    return $result;
}

# Генерація підключів із 256-бітного ключа
sub generate_keys {
    my ($key) = @_;
    my @keys = unpack("N8", $key);
    return \@keys;
}

1;  # Повертати істинне значення для правильного завершення модуля

