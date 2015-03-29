#$ -o /home/inutano/project/ER/log -S /bin/bash -j y -l mem_req=4G,s_vmem=4G -pe def_slot 1
# ls data/*.sra | sed -e 's:data/::g' | while read f ; do ; qsub -N $f simple_fastqc.sh $f ; done

# Get a path to dump command
fqdump="/home/inutano/local/bin/sratoolkit/fastq-dump --gzip --split-3"

# Acquiring Location..
BASEDIR="/home/inutano/project/ER"
fqdir="${BASEDIR}/fastq"

# extract id from file name since argument 1 is a path to sra file
id=`echo $1 | sed -e 's:\.sra$::' | sed -e 's:\.lite$::'`

if [ -e "/ssd" ] ; then
  stage=/ssd/$id
  mkdir -p $stage
  mv $1 $stage
  cd $stage && ls *sra | xargs $fqdump
  mv ${stage}/*fastq.gz $fqdir && rm -fr $stage || rm -fr $stage && echo $1 >> ${BASEDIR}/table/fqdumpfailed
else
  cd "${BASEDIR}/data"
  $fqdump $1 && rm -f $1
  id=`echo $1 | sed -e 's:\.sra$::' | sed -e 's:\.lite$::'`
  mv ${id}*.fastq.gz $fqdir
fi
