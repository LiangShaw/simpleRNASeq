#!/usr/bin/bash

### Usage:
###   rmats_JC_stat.sh <rmats.directory> <PVthres> <FDRthres> <PSIthres>
### Options:
###   <rmats.directory>      rmats output directory
###   <PVthres>              Pvalue threshold
###   <FDRthres>             FDR threshold
###   <PSIthres>             deltaPSI threshold
###   -h                     Show this message.

help() {
    sed -rn 's/^### ?//;T;p;' "$0"
}

if [[ $# == 0 ]] || [[ "$1" == "-h" ]]; then
  help
  exit 1
fi


pdir=$1
PVthres=$2
FDRthres=$3
PSIthres=$4

mkdir $pdir/JC-stat-res/

ls $pdir | grep JC.txt | grep -v MXE | while read id;do cat $pdir/$id | awk -v id=${id%%.*} '{
    gsub(/^"|"$/, "", $2); gsub(/^"|"$/, "", $3); \
    eventid=$4"|"$5"|"$6"|"$7"|"$8"|"$9"|"$10"|"$11; \
    printf $2"\t"$3"\t"eventid"\t"; \
    printf $13"\t"$14"\t"$15"\t"$16"\t" ; \
    for (i=19;i<=NF;i++) printf $i"\t";print id}' > $pdir/JC-stat-res/${id%%.*}.maincol.txt;done

cat $pdir/MXE.MATS.JC.txt | awk -v id=MXE '{
    gsub(/^"|"$/, "", $2); gsub(/^"|"$/, "", $3); \
    eventid=$4"|"$5"|"$6"|"$7"|"$8"|"$9"|"$10"|"$11"|"$12"|"$13; \
    printf $2"\t"$3"\t"eventid"\t"; \
    printf $15"\t"$16"\t"$17"\t"$18"\t" ; \
    for (i=21;i<=NF;i++) printf $i"\t";print id}' > $pdir/JC-stat-res/MXE.maincol.txt

head -n 1 $pdir/JC-stat-res/SE.maincol.txt | awk 'BEGIN{OFS="\t"}{for (i=1;i<NF;i++) printf $i"\t";print "EventType"}' > $pdir/JC-stat-res/events.merge.maincol.txt

ls $pdir/JC-stat-res/*.maincol.txt  | grep -v merge | while read id;do cat $id | awk 'NR>1' ;done >> $pdir/JC-stat-res/events.merge.maincol.txt

less $pdir/JC-stat-res/events.merge.maincol.txt | awk -v PVthres=$PVthres -v FDRthres=$FDRthres -v dPSI=$PSIthres 'NR==1 || $8<PVthres && $9<FDRthres && ($12>=dPSI || $12<=-dPSI)' > $pdir/JC-stat-res/events.merge.maincol.PV${PVthres}_FDR${FDRthres}_dPSI${PSIthres}.txt
