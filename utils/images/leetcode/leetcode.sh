#!/bin/sh

NUM=$1

wget "https://leetcode.com/api/problems/all" -q -O - | jq > leetcode_problems
INFO=$(jq -c "[.stat_status_pairs[] | {id: .stat.question_id, title: .stat.question__title, difficulty: .difficulty.level}] | .[] | select(.id == $NUM)" leetcode_problems)

TITLE=$(echo $INFO | jq -c -r '.title')
DIFFICULTY_NUM=$(echo $INFO | jq -c -r '.difficulty' )

if [[ $DIFFICULTY_NUM -eq 1 ]]
then
  DIFFICULTY="Easy"
fi

if [[ $DIFFICULTY_NUM -eq 2 ]]
then
  DIFFICULTY="Medium"
fi

if [[ $DIFFICULTY_NUM -eq 3 ]]
then
  DIFFICULTY="Hard"
fi

LABEL="$TITLE\nProblem $NUM ($DIFFICULTY)"

echo "Making image for..."
echo $LABEL

# https://legacy.imagemagick.org/Usage/text/ - Caption will word-wrap

convert -background white -fill black -font /fonts/MesloLGS\ NF\ Regular.ttf -pointsize 42 label:"$LABEL" _label.png
composite -compose atop -gravity north leetcode_logo.png blank.png _logo.png
composite -compose atop -gravity center -geometry +0+90 _label.png _logo.png leetcode_"$NUM"_header.png

rm _*.png
rm leetcode_problems
