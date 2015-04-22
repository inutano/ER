#!/bin/zsh
echo "total number of job:"
/home/geadmin/UGER/bin/lx-amd64/qstat | awk '$5 ~ /^(qw|r)$/ {print $1}' | wc -l
echo ""
echo "Job count ranking"
echo "running"
/home/geadmin/UGER/bin/lx-amd64/qstat -u "*" | awk '$5 == "r" {print $4}' | sort | uniq -c | sort -nr | head -5
echo "waiting"
/home/geadmin/UGER/bin/lx-amd64/qstat -u "*" | awk '$5 == "qw" {print $4}' | sort | uniq -c | sort -nr | head -5
echo ""
echo "number of .sra files"
ls /home/inutano/project/ER/data/*sra 2>/dev/null | wc -l
echo "number of .bz2 files"
ls /home/inutano/project/ER/data/*bz2 2>/dev/null | wc -l
echo "number of .fastq files"
ls /home/inutano/project/ER/fastq/*fastq 2>/dev/null | wc -l
echo "number of .fastq.gz files"
ls /home/inutano/project/ER/fastq/*fastq.gz 2>/dev/null | wc -l
echo "number of fastqc result files"
ls /home/inutano/project/ER/fastq/*zip 2>/dev/null | wc -l
echo ""
echo "disk size"
du -h /home/inutano/project/ER/data/ 2>/dev/null
du -h /home/inutano/project/ER/fastq/ 2>/dev/null
du -h /home/inutano/project/ER/fqdumpfailed/ 2>/dev/null
