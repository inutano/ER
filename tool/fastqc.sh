#$ -o /home/inutano/project/ER/log -S /bin/bash -j y -l mem_req=2G,s_vmem=2G -pe def_slot 4
# Usage:
#   fastqc.sh /path/to/DRR000001.fastq.gz
set -u

## User Setting
# path to fastqc command
fastqc="/home/inutano/local/bin/fastqc --threads 4 --noextract"

# working directory
DIR_IN="/home/inutano/project/ER/fastq"
DIR_OUT="/home/inutano/project/ER/fastq"
FQLOG="/home/inutano/project/ER/table/fqdumpfailed"

## Run fastqc
# File exist?
filepath=${1}
if [ ! -e ${filepath} ] ; then
  exit 1
fi

# Extract filename and ID from file path
filename=`echo ${filepath} | tr '/' '\n' | awk '$0 ~ /^.RR/'`
id=`echo ${filename} | awk -F '.' '{ print $1 }'`

# run on /ssd if available
#if [ -e "/ssd" ] ; then
#  stage=/ssd/fastqc/${id}
#  mkdir -p ${stage}
#  mv ${filepath} ${stage}
#  cd ${stage}
#  ${fastqc} ${filename} && mv ${stage}/*.zip ${DIR_OUT} && rm -fr ${stage} || rm -fr ${stage} && echo ${filepath} >> ${FQLOG}
#else
  cd ${DIR_IN}
  ${fastqc} ${filepath} && rm -f ${filepath}
#fi
