#!/bin/bash
# Concatenate all commanline params and print result

result=""

for var in "$@"
do
  result=${result}${var}
done

echo $result

