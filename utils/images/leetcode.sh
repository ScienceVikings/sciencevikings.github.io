#!/bin/sh

NUM=$1


jq '[.stat_status_pairs[] | {id: .stat.question_id, title: .stat.question__title, difficulty: .difficulty.level}]' leetcode_problems

# wget https://leetcode.com/api/problems/all -q -O - | jq > leetcode_problems

# wget https://leetcode.com/api/problems/all -q -O - | jq .stat_status_pairs[].stat > leetcode_problems

# .stat_status_pairs[].stat

# convert -background white -fill black -font /fonts/MesloLGS\ NF\ Regular.ttf -pointsize 36 label:LeetCode leetcode_words.png
