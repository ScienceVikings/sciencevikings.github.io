#!/bin/sh

NUM=$1

if [ -z "$NUM" ]
then
  echo "Pass a LeetCode problem number."
  echo "ex: ./leetcode.sh 34"
  return
fi

wget "https://leetcode.com/api/problems/all" -q -O - | jq > leetcode_problems
INFO=$(jq -c "[.stat_status_pairs[] | {id: .stat.question_id, title: .stat.question__title, difficulty: .difficulty.level}] | .[] | select(.id == $NUM)" leetcode_problems)

TITLE=$(echo $INFO | jq -c -r '.title')
DIFFICULTY_NUM=$(echo $INFO | jq -c -r '.difficulty' )

if [[ $DIFFICULTY_NUM -eq 1 ]]
then
  DIFFICULTY="Easy"
  DIFFICULTY_COLOR="#5cb85c"
fi

if [[ $DIFFICULTY_NUM -eq 2 ]]
then
  DIFFICULTY="Medium"
  DIFFICULTY_COLOR="#f0ad4e"
fi

if [[ $DIFFICULTY_NUM -eq 3 ]]
then
  DIFFICULTY="Hard"
  DIFFICULTY_COLOR="#d9534f"
fi

LABEL="$TITLE | $DIFFICULTY"

echo "Making image for problem #$NUM"
echo $LABEL

# https://legacy.imagemagick.org/Usage/text/ - Caption will word-wrap

convert -background transparent -fill white -gravity center -font /fonts/MesloLGS\ NF\ Regular.ttf -size 250x -pointsize 42 caption:"$DIFFICULTY" _difficulty_text.png
convert -background white -fill black -font /fonts/MesloLGS\ NF\ Regular.ttf -size 725x -pointsize 42 caption:"Problem #$NUM" _problem_num.png

MAX_SIZE=84
POINT_SIZE=$(convert -size 725x185 -font /fonts/MesloLGS\ NF\ Regular.ttf caption:"$TITLE" -format "%[caption:pointsize]" info:)

if [[ $POINT_SIZE -gt $MAX_SIZE ]]
then
  convert -background white -fill black -font /fonts/MesloLGS\ NF\ Regular.ttf -size 725x185 -pointsize $MAX_SIZE caption:"$TITLE" _title.png
else
  convert -background white -fill black -font /fonts/MesloLGS\ NF\ Regular.ttf -size 725x185 caption:"$TITLE" _title.png
fi

convert -size 250x50 xc:white -fill "$DIFFICULTY_COLOR" -draw "roundrectangle 0,0 250,50 25,50" _difficulty_rect.png

composite -compose atop -gravity north leetcode_logo.png blank.png _logo.png #Logo onto the blank
composite -compose atop -gravity center _difficulty_text.png _difficulty_rect.png _difficulty.png #Text onto difficulty
composite -compose atop -gravity center -geometry +140+25 _problem_num.png _logo.png _logo.png #Problem number line
composite -compose atop -gravity center -geometry +140+160 _title.png _logo.png _logo.png #Problem Title
composite -compose atop -gravity west -geometry +0+60 _difficulty.png _logo.png _logo.png #Difficulty Rect
convert -bordercolor white -border 100x20 _logo.png ../leetcode_"$NUM"_header.png #final

#now resize
cd ..
./resize.sh leetcode_"$NUM"_header.png

cd leetcode

rm _*.png
rm leetcode_problems
