# -*- coding: utf-8 -*-

require "rake"
require "fileutils"
require "systemu"

Basedir = "/home/inutano/project/ER"

def fastq_order_by_size
  fastq_dir = Basedir + "/fastq"
  fq_files = Dir.glob(fastq_dir + "/*fastq") + Dir.glob(fastq_dir + "/*fastq.gz")
  fq_files.sort_by{|f| File.size(f) }
end

def qsub_fastqc(queue, fastq)
  job_name = fastq.split("/").last.slice(0..8) + "F"
  script_path = Basedir + "/tool/fastqc.sh"
  qsub = "/home/geadmin/UGER/bin/lx-amd64/qsub -N #{job_name} -l #{queue} #{script_path} #{fastq}"
  status, stdout, stderr = systemu(qsub)
  raise RuntimeError if status.exitstatus != 0
  puts [qsub, stdout]
  stdout.split("\s")[2] # return job id
rescue NameError, RuntimeError
  sleep 180
  retry
end

def job_finished?(jobid)
  qstat = "/home/geadmin/UGER/bin/lx-amd64/qstat | awk '$1 == #{jobid}'"
  status, stdout, stderr = systemu(qstat)
  raise RuntimeError if status.exitstatus != 0
  stdout.empty?
end

def disk_full?
  data_usage = `du /home/inutano/project/ER/data 2> /dev/null | cut -f 1`.chomp.to_i
  fastq_usage = `du /home/inutano/project/ER/fastq 2> /dev/null | cut -f 1`.chomp.to_i
  disk_usage = data_usage + fastq_usage
  if fastq_usage > 20_000_000_000 or disk_usage > 40_000_000_000
    true
  end
end

if __FILE__ == $0
  GEQueue = ARGV.first || "short"
  
  while true
    # anytime disk full: fastqc only reduces the size
    #if disk_full?
    #  puts "Disk quota nearly exceeded: sleep until anyone is out " + Time.now.to_s
    #  while disk_full?
    #    sleep 10
    #  end
    #end

    fastq_list = fastq_order_by_size

    # no file to dump
    if fastq_list.empty?
      puts "No file to be processed: sleep until new guys are coming " + Time.now.to_s
      while fastq_list.empty?
        sleep 10
        fastq_list = fastq_order_by_size
      end
    end
    
    # job submission
    job_box = []
    fastq_list.each do |fastq|
      job_box << qsub_fastqc(GEQueue, fastq)
    end
    puts job_box.length.to_s + " jobs submitted " + Time.now.to_s
    
    # waiting for submitted job to finish
    job_box.each do |job_id|
      while !job_finished?(job_id)
        sleep 7
      end
    end
    
    # flush fastqc directory
    `#{Basedir}/tool/mv_fastqc.sh`
  end
end
