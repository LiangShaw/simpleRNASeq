### Description:
###   Retained introns are coped differently. This script is used to combine RI and other event types under different version.
### Usage:
###   combine_RI_and_others.sh <routineRmatsMainCol> <RIRmatsMainCol> <output> <PVthres> <FDRthres> <PSIthres>
### Options:
###   <routineRmatsMainCol>   rmats output miancol txt (general)
###   <RIRmatsMainCol>       rmats output miancol txt (for RI)
###   <output>               output prefix
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


maintxt=$1
RItxt=$2
combine=$3

PVthres=$4
FDRthres=$5
PSIthres=$6

awk '$9!="IR"' ${maintxt} | cat - ${RItxt} | awk -v PVthres=$PVthres -v FDRthres=$FDRthres -v dPSI=$PSIthres 'NR==1 || $8<PVthres && $9<FDRthres && ($12>=dPSI || $12<=-dPSI)' > ${combine}.events.merge.maincol.PV${PVthres}_FDR${FDRthres}_dPSI${PSIthres}.txt
