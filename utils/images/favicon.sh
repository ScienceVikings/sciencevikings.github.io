#!/bin/sh
IMG_FILE=$1
NAME=$(echo "$IMG_FILE" | cut -f 1 -d '.')
EXT=$(echo "$IMG_FILE" | cut -f 2 -d '.')
SIZE=512
DIMS=$(echo $SIZE)x$(echo $SIZE)

mkdir -p output

# The order of the commands to convert matters.
convert $IMG_FILE -resize $DIMS output/icon-$DIMS.png

SIZE=384
DIMS=$(echo $SIZE)x$(echo $SIZE)
convert $IMG_FILE -resize $DIMS output/icon-$DIMS.png

SIZE=192
DIMS=$(echo $SIZE)x$(echo $SIZE)
convert $IMG_FILE -resize $DIMS output/icon-$DIMS.png

SIZE=152
DIMS=$(echo $SIZE)x$(echo $SIZE)
convert $IMG_FILE -resize $DIMS output/icon-$DIMS.png

SIZE=144
DIMS=$(echo $SIZE)x$(echo $SIZE)
convert $IMG_FILE -resize $DIMS output/icon-$DIMS.png

SIZE=128
DIMS=$(echo $SIZE)x$(echo $SIZE)
convert $IMG_FILE -resize $DIMS output/icon-$DIMS.png

SIZE=96
DIMS=$(echo $SIZE)x$(echo $SIZE)
convert $IMG_FILE -resize $DIMS output/icon-$DIMS.png

SIZE=72
DIMS=$(echo $SIZE)x$(echo $SIZE)
convert $IMG_FILE -resize $DIMS output/icon-$DIMS.png

