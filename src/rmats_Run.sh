#!/usr/bin/bash

### Usage:
###   AS_rmats.sh <gtf> <b1list> <b2list> <od> <thread> <readlen> <mode>
###   Please set rmats pathway manually.
### Options:
###   <gtf>      gtf file
###   <b1list>   treatment bam file list. "," separates multi bam names
###   <b2list>   control bam file list. "," separates multi bam names
###   <od>       Output directory. tmp files are inside it
###   <thread>   thread number
###   <readlen>  read length
###   <mode>     paried or single read
###   -h         Show this message.

help() {
    sed -rn 's/^### ?//;T;p;' "$0"
}

if [[ $# == 0 ]] || [[ "$1" == "-h" ]]; then
  help
  exit 1
fi

gtf=$1
b1files=$2
b2files=$3
od=$4
thread=$5
readlen=$6
mode=$7
tmp=${od}/tmp/

mkdir -p $od

~/miniconda2/envs/snakemake/bin/rmats.py --gtf ${gtf} --b1 ${b1files} --b2 ${b2files} --od ${od} --tmp ${tmp} -t ${mode} --readLength ${readlen} --variable-read-length --nthread ${thread} --novelSS
