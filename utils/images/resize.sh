#!/bin/sh

IMG_FILE=$1
NAME=$(echo "$IMG_FILE" | cut -f 1 -d '.')
EXT=$(echo "$IMG_FILE" | cut -f 2 -d '.')

mkdir -p output

ORIG_WIDTH=$(identify $IMG_FILE | cut -f 3 -d ' ' | cut -f 1 -d 'x')
ORIG_HEIGHT=$(identify $IMG_FILE | cut -f 3 -d ' ' | cut -f 2 -d 'x')

NEW_HEIGHT=$(($ORIG_WIDTH*1080/1920))
BORDER_HEIGHT=$((($NEW_HEIGHT - $ORIG_HEIGHT)/2))

# 1075w x 353h
# 1920w x 1080h

# img width * 1080/1920 = height we want
# height div 2
echo "New Height: $NEW_HEIGHT"
echo "Orig Height: $ORIG_HEIGHT"
echo "Border: $BORDER_HEIGHT"
# The order of the commands to convert matters.
# 'rgb(18,25,38)'
convert $IMG_FILE -bordercolor white -border 0x$BORDER_HEIGHT output/$IMG_FILE
# convert $IMG_FILE -border 100 -resize 50%  output/$NAME@0,5x.$EXT
# convert $IMG_FILE -border 100 -resize 25%  output/$NAME@0,25x.$EXT
# convert $IMG_FILE -border 100 -resize 12.5% output/$NAME@0,125x.$EXT
