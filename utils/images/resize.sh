#!/bin/sh

IMG_FILE=$1
NAME=$(echo "$IMG_FILE" | cut -f 1 -d '.')
EXT=$(echo "$IMG_FILE" | cut -f 2 -d '.')

mkdir -p output

# The order of the commands to convert matters.
convert $IMG_FILE -border 100 output/$IMG_FILE
convert $IMG_FILE -border 100 -resize 50%  output/$NAME@0,5x.$EXT
convert $IMG_FILE -border 100 -resize 25%  output/$NAME@0,25x.$EXT
convert $IMG_FILE -border 100 -resize 12.5% output/$NAME@0,125x.$EXT
