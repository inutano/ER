#$ -o /home/inutano/project/ER/log -S /bin/bash -j y -l mem_req=4G,s_vmem=4G -pe def_slot 1
# ls data/*.sra | sed -e 's:data/::g' | while read f ; do ; qsub -N $f simple_fastqc.sh $f ; done

cd /home/inutano/project/ER/data
/home/inutano/local/bin/sratoolkit/fastq-dump --split-3 $1 && rm -f $1
id=`echo $1 | sed -e 's:\.sra$::' | sed -e 's:\.lite$::'`
ls /home/inutano/project/ER/data | awk '$0 ~ /'"${id}"'/' | xargs -0 mv -t /home/inutano/project/ER/fastq
