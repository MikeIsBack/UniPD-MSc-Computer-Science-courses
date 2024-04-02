#!/usr/bin/env bash

if [[ $1 == '-c' ]]; then
    compact=true
else
    compact=false
fi

declare -A dict
# Initial code value
code=256

# Table header
echo w$'\t'k$'\t'output$'\t'code =\> symbol
echo ======================================

# Actual algorithm implementation
while read k && [[ -n $k ]]; do
    # Trace the input while reading k
    input="$input $k"

    # Check if wk is in dictionary
    if [[ -n ${dict[$w$k]} ]]; then
        w=$w$k
        # Print extended output only if option -c was not provided
        $compact || echo $w$'\t'$k
    else
        # Add normal characters to dictionary with their own symbol (instead of code)
        if [[ -z ${dict[$k]} ]]; then
            dict+=([$k]=$k)
        fi

        # Do only if it's not the first iteration (w is empty)
        if [[ -n $w ]]; then
            # Add wk => code to dictionary
            # using wk as key makes retrieving the code for printing and existting checks easier
            dict+=([$w$k]=$code)
            echo $w$'\t'$k$'\t'${dict[$w]}$'\t'$code =\> $w$k
            # Trace the encoded sequence
            enc="$enc ${dict[$w]}"
            code=$(( $code + 1 ))
        else
            $compact || echo NULL$'\t'$k
        fi
        w=$k
    fi
done
# Print last line
enc="$enc ${dict[$w]}"
echo $w$'\t'EOF$'\t'${dict[$w]}

echo $'\n'Encoded sequence:
echo $enc

# Compress ratio output
o_size=$(echo $input | wc -w | sed -e 's/[^0-9]*//g')
o_bits=$(( $o_size * 8 ))
echo $'\n'Original size: $o_size bytes \* 8 = $o_bits bits

e_size=$(echo $enc | wc -w | sed -e 's/[^0-9]*//g')

e_bytes=$(echo $enc | sed -e 's/[0-9][0-9][0-9]//g' | wc -w | sed -e 's/[^0-9]*//g')
e_codes=$(echo $enc | sed -e 's/[^0-9 ]//g' | sed -e 's/[^0-9]. / /g' | wc -w | sed -e 's/[^0-9]*//g')

echo $'\n'- ASCII 1 byte, codes 9 bits:
e_bits=$(( $e_bytes * 8 + e_codes * 9 ))
echo "Encoded size: $e_size characters -> $e_bytes characters * 8 + $e_codes codes * 9 = $e_bits bits"
printf 'Encoding ratio: %.3f\n' $(bc -le "$e_bits / $o_bits")

echo $'\n'- 9 bits per character:
e_bits=$(( $e_bytes * 9 + e_codes * 9 ))
echo "Encoded size: $e_size characters * 9 = ($e_bytes characters + $e_codes codes) * 9 = $e_bits bits"
printf 'Encoding ratio: %.3f\n' $(bc -le "$e_bits / $o_bits")

echo $'\n'- ASCII 1 byte, codes 2 bytes:
e_bits=$(( $e_bytes * 8 + e_codes * 16 ))
echo "Encoded size: $e_size characters -> $e_bytes characters * 8 + $e_codes codes * 16 = $e_bits bits"
printf 'Encoding ratio: %.3f\n' $(bc -le "$e_bits / $o_bits")
