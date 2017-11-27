#!/bin/bash

clear
echo -n > search_word.txt

word=$1
echo "You want to search by the word: $1"
cd words

#SEARCH IN ALL FILES THE WORD GIVEN BY THE PARAMETER AND SAVE IN THE SEARCH_WORD.TXT
grep -R $word . >> ../search_word.txt

num=0
count=0
cd ..

echo "Files where you can find the word: $1"
echo
cat search_word.txt


while read line;
do
        #READ THE OCCURRENCES OF THE WORD IN EACH FILE AND CALCULATE THE TOTAL
        num=$(echo $line | grep -oP '(?<=\[)[^\]]+')
        count=$((count+num))


done < search_word.txt


echo
echo "Total of occurrences: $count"
