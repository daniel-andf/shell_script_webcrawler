#!/bin/bash

clear
# DELETE ALL FOLDERS AND FILES CREATED FOR THE WEB CRAWLER
rm -r urls
rm -r words

echo -n > linksunread.txt
echo -n > linksread.txt

#CREATE FOLDERS THAT WILL BE USED BY THE WEB CRAWLER
mkdir urls
cd urls
mkdir done

cd ..

mkdir words
cd words
mkdir todo

cd ..


echo "=======================START WEB CRAWLER========================"

#READ FIRST LINK FROM WIKIPEDIA
echo "https://en.wikipedia.org/wiki/Cloud_computing" >> linksunread.txt
links=linksunread.txt
count=0
check=0
count_dup=0

while read files && [[ "$count" -lt 10 ]]
#THIS LOOP WILL READ EACH LINK FROM linksunread.txt OR UNTIL THE LIMIT DEFINE BY THE count VARIABLE
 do

        echo "Reading $files"
        echo ""
        cd urls #THE ARCHIVE DOWNLOADED WILL BE STORED ON THE urls FOLDER
        filename="$files.txt"

        filename=${filename//\/}
        filename=${filename//"http:"}
        filename=${filename//"https:"}
        # SET filename VARIABLE TO STORE ALL WORDS FROM A PARTICULAR WEBSITE. IT WAS NECESSARY TO REMOVE SLASHES AND HTTP(S) TO NOT GET A ERROR WHILE CREATING A FILE

        curl -O -0 $files #UPLOAD THE WEBSITE
        res=$?

        cd ..

        if [ "$res" = "0" ]
        then
                count=$((count+1))
                check=1
        else
                echo "There is no valid content"
                echo ""

        fi
          #THIS CONDITION IS TO MAKE SURE THAT THE PROGRAM COUNT EACH TIME IT DOWNLOADED THE CONTENT FROM A WEBSITE. IF THERE IS ANY ERROR, THE PROGRAM WILL NOT CONSIDER AS
          #THE LINK WAS READ

        if [ $check -eq 1 ]
        then
                echo "Extracting links and words from $files"
                echo ""

                cd urls
                for file in *
                do
                        if [ $file != "done" ] && [ $file != "temp" ]
                        then
                        grep -Eos '(http|https)://[a-zA-Z0-9./?=_-]*wiki[a-zA-Z0-9./?=_-]*' $file | sort | uniq >> ../$links
                        #GET ALL LINKS THAT EXIST IN ONE WEBSITE,SORT THE LIST AND MAKE SURE THAT THERE IS NO LINK REPETITION

                        grep -Evs '.pdf|.png|.txt|.jpg|.svg|.gif' $links > temp && mv temp $links #REMOVE TEXT AND IMAGE EXTENSIONS

                        while read line
                        do
                                for word in $line
                                #GET EACH WORD FROM A PARTICULAR LINE AND SAVE TO A TEMPORARY FILE
                                do
                                        grep -o -h -w -E '\w+' -s $word  >> ../words/todo/temp.txt
                                        sort ../words/todo/temp.txt > ../words/todo/word_count_temp.txt
                                done
                        done < $file

                        chmod 744 $file
                        mv --backup=numbered $file done


                        grep -vs $files $links > temp && mv temp $links #WHEN WE FINISHED TO READ THE WEBSITE FROM ONE LINK, REMOVE THIS FROM THE FILE linksunreaded.txt
                        fi
                done

                cd ..
                echo $files >> linksread.txt

                echo "Links and words successfully extracted from $files"
                echo ""



                if [ -f "words/$filename" ]
                then
                        count_dup=$((count_dup+1))
                        filename=$filename"_"$count_dup
                        echo $files >> words/$filename
                else
                        echo $files >> words/$filename
                fi

                echo -n > words/todo/temp.txt

                last_word=''
                i=0

                echo "Sorting and counting words from $files"
                echo ""


                for file in words/todo/*; #COUNT EVERY WORDS, SORT THE LIST AND SAVE IN A FILE THAT IS RELATED TO THE LINK THAT WAS READ BY THE PROGRAM
                do
                        while read line;
                        do
                                for word in $line
                                do
                                        if [ "$word" = "$last_word" ]
                                        then
                                                i=$((i+1))
                                                last_word=$word
                                        elif [ "$last_word" = "" ]
                                        then
                                                i=$((i+1))
                                                                                                                                                      else
                                                echo "$last_word [$i]" >> words/$filename
                                                i=1
                                                last_word=$word
                                        fi
                                done

                        done < $file


                done
                echo "Words sorted and counted successfully from $files"
                echo ""

                echo -n > words/todo/word_count_temp.txt
        fi
        check=0

echo "file number: $count"
done < $links


rm -r words/todo
rm -r urls/temp

echo "==============================END OF CRAWLER======================================"
