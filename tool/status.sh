#!/bin/bash
echo "Jobs in the queue:             `/home/geadmin/UGER/bin/lx-amd64/qstat | awk '$5 ~ /^(qw|r)$/ { print $1 }' | wc -l`"
echo "Jobs running on phase 1 nodes: `/home/geadmin/UGER/bin/lx-amd64/qstat | awk '$5 == "r" && $8 !~ /^dbcls/ { print $1 }' | wc -l`"
echo "Jobs running on DBCLS nodes:   `/home/geadmin/UGER/bin/lx-amd64/qstat -l dbcls | awk '$5 == "r" && $8 ~ /^dbcls/ { print $1 }' | wc -l`"
echo "Jobs waiting:                  `/home/geadmin/UGER/bin/lx-amd64/qstat | awk '$5 == "qw" { print $1 }' | wc -l`"
echo "---"
echo "fastq-dump jobs: `qstat -r | grep -B1 jobname | grep sradump | wc -l`"
echo "fastqc jobs:     `qstat -r | grep -B1 jobname | grep fastqc | wc -l`"
echo "---"
echo "Job count ranking"
echo "running"
/home/geadmin/UGER/bin/lx-amd64/qstat -u "*" | awk '$5 == "r" {print $4}' | sort | uniq -c | sort -nr | head -5
echo "waiting"
/home/geadmin/UGER/bin/lx-amd64/qstat -u "*" | awk '$5 == "qw" {print $4}' | sort | uniq -c | sort -nr | head -5
echo "---"
echo ".sra files in data: `ls /home/inutano/project/ER/data/*sra 2>/dev/null | wc -l`"
echo ".bz2 files in data: `ls /home/inutano/project/ER/data/*bz2 2>/dev/null | wc -l`"
echo "---"
#echo "number of .fastq files"
#ls /home/inutano/project/ER/fastq/*fastq 2>/dev/null | wc -l
echo ".fastq.gz files in fastq:  `ls /home/inutano/project/ER/fastq/*fastq.gz 2>/dev/null | wc -l`"
echo ".fastq.bz2 files in fastq: `ls /home/inutano/project/ER/fastq/*fastq.bz2 2>/dev/null | wc -l`"
echo ".fastqc result files:      `ls /home/inutano/project/ER/fastq/*zip 2>/dev/null | wc -l`"
echo "---"
echo "disk size"
du -h /home/inutano/project/ER/data/ 2>/dev/null
du -h /home/inutano/project/ER/fastq/ 2>/dev/null
#du -h /home/inutano/project/ER/fqdumpfailed/ 2>/dev/null
