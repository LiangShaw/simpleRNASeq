#!/usr/bin/bash

### Usage:
###   rmats_AS_range.sh <rmats.maincolumn.file>
### Options:
###   <rmats.maincolumn.file>  rmats maincolumn file generated using rmats_JC_stat.sh
###   -h                       Show this message.

help() {
    sed -rn 's/^### ?//;T;p;' "$0"
}

if [[ $# == 0 ]] || [[ "$1" == "-h" ]]; then
  help
  exit 1
fi

file=$1

cat $file | awk 'BEGIN{OFS="\t"}NR>1{split($3,cor,"|");  
    gsub(/^"|"$/, "", $2);
    chr=cor[1]; strand=cor[2];
    min = max = cor[3];
    for (i = 4; i <= length(cor); i++) {
        if (cor[i] < min) min = cor[i];
        if (cor[i] > max) max = cor[i];
    }; print chr,min,max,$2,1000,strand,$8,$9,$12,$13}' | sort -k1,1 -k2,2n -k3,3n > ${file%.*}.max_AS_range.bed

mergeBed -i ${file%.*}.max_AS_range.bed -s -c 4,5,6 -o  distinct > ${file%.*}.max_AS_range.mergeBed.bed