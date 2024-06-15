#!/usr/bin/bash

### Usage:
###   rmats_filter_low_reads.sh <rmats_result_maincol> <read_num>
### Options:
###   <rmats_result_maincol>      rmats output result file including only main columns
###   <read_num>             minimum read number
###   <method>               count stat method (average in default) for each group (IJC_SAMPLE_1, SJC_SAMPLE_1, IJC_SAMPLE_2, SJC_SAMPLE_2)
###   -h                     Show this message

help() {
    sed -rn 's/^### ?//;T;p;' "$0"
}

if [[ $# == 0 ]] || [[ "$1" == "-h" ]]; then
  help
  exit 1
fi


input=$1
readNum=$2

cat $input | awk -v read=$readNum 'BEGIN{FS="\t"}{if (NR==1) {print $0; next} \
                  else {split($4,IJC1,","); split($5,SJC1,","); split($6,IJC2,","); split($7,SJC2,","); \
                        count = length(IJC1) ; IJC1sum=0;SJC1sum=0;IJC2sum=0;SJC2sum=0; \
                        for (i=1;i<=count;i++) {IJC1sum+=IJC1[i]; SJC1sum+=SJC1[i]; IJC2sum+=IJC2[i]; SJC2sum+=SJC2[i]}; \
                        IJC1ave=IJC1sum/count; SJC1ave=SJC1sum/count; IJC2ave=IJC2sum/count; SJC2ave=SJC2sum/count;
                        if ( (IJC1ave>=read || SJC1ave>=read) && (IJC2ave>=read || SJC2ave>=read) ) {print $0} else {}
                   } } ' > ${input%.*}.min_read_${readNum}.txt

# if ( (IJC1ave>=read || SJC1ave>=read) ) {print $0} else if (IJC2ave>=read || SJC2ave>=read) {print $0} else {}