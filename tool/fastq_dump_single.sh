#$ -o /home/inutano/project/ER/log -S /bin/bash -j y -l mem_req=4G,s_vmem=4G -pe def_slot 1
# Usage:
#   fastq_dump.single.sh /path/to/DRR000001.sra
# Interactive Run:
#   ls data/*.sra | sed -e 's:data/::g' | while read f ; do ; qsub -N $f fastq_dump_single.sh $f ; done

set -u

## User Setting
# path to dump command
fqdump="/home/inutano/local/bin/sratoolkit/fastq-dump --gzip --split-3"

# working directory
DIR_IN="/home/inutano/project/ER/data"
DIR_OUT="/home/inutano/project/ER/fastq"
FQLOG="/home/inutano/project/ER/table/fqdumpfailed"

## Run fastq-dump
# File exist?
filepath=${1}
if [ ! -e ${filepath} ] ; then
  exit 1
fi

# Extract filename and ID from file path
filename=`echo ${filepath} | tr '/' '\n' | awk '$0 ~ /^.RR/'`
id=`echo ${filename} | awk -F '.' '{ print $1 }'`

# dump on /ssd if available
if [ -e "/ssd" ] ; then
  stage=/ssd/fqdump/${id}
  mkdir -p ${stage}
  mv ${filepath} ${stage}
  cd ${stage}
  ${fqdump} ${filename} && mv ${stage}/*fastq* ${DIR_OUT} && rm -fr ${stage} || rm -fr ${stage} && echo ${filepath} >> ${FQLOG}
else
  cd ${DIR_IN}
  ${fqdump} ${filepath} && mv ${id}*fastq* ${DIR_OUT} && rm -f ${filepath}
fi
