#!/usr/bin/env bash

f=00
zero=10
a=01
b=110
c=111

read input

enc=$(echo $input | sed -e 's/./& /g' | sed -e "s/0/$zero/g" | sed -e "s/f/$f/g" | sed -e "s/a/$a/g" | sed -e "s/b/$b/g" | sed -e "s/c/$c/g")
echo Encoded sequence:
echo $enc

# Compress ratio
o_size=$(echo $input | sed -e 's/./& /g' | wc -w | sed -e 's/[^0-9]*//g')
o_bits=$(( $o_size * 8 ))
echo $'\n'Original size: $o_size bytes \* 8 = $o_bits bits

e_bits=$(echo $enc | sed -e 's/[^ ]/& /g' | wc -w | sed -e 's/[^0-9]*//g')
echo Encoded size: $e_bits bits

# Table size
t_bits=$(( 5 * 2 * 8 ))
echo Encoded size \(with table\): \(5 \* 2\) bytes \* 8 = $(( $e_bits + $t_bits )) bits

printf '\nEncoding ratio: %.3f\n' $(bc -le "($e_bits + $t_bits) / $o_bits")
