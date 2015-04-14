# -*- coding: utf-8 -*-

require "systemu"

Basedir = "/home/inutano/project/ER"
GEadmin = "/home/geadmin/UGER/bin/lx-amd64"

def data_sort_by_size
  ## Create a list of path to data sorted by data size
  data_dir = Basedir + "/data"
  sra_files = Dir.glob(data_dir + "/*sra")
  sra_files.sort_by{|f| File.size(f) }
end

def disk_full?
  data_usage = `du /home/inutano/project/ER/data 2>/dev/null | cut -f 1`.chomp.to_i
  fastq_usage = `du /home/inutano/project/ER/fastq 2>/dev/null | cut -f 1`.chomp.to_i
  disk_usage = data_usage + fastq_usage
  fastq_usage > 20_000_000_000 or disk_usage > 35_000_000_000
end

def check_volume
  ## wait if disk full
  if disk_full?
    puts "DISK FULL: WAIT, SINCE " + Time.now.to_s
    while disk_full?
      sleep 10
    end
  end
  true
end

def submit_fqdump(fpath, queue)
  job_name = fpath.split("/").last.slice(0..8) + "D"
  script_path = Basedir + "/tool/fastq_dump_single.sh"
  status, stdout, stderr = systemu("/home/geadmin/UGER/bin/lx-amd64/qsub -N #{job_name} -l #{queue} #{script_path} #{fpath}")
  raise RuntimeError if status.exitstatus != 0
  puts stdout
  stdout.split("\s")[2] # return job id
rescue NameError, RuntimeError
  sleep 180
  retry
end

if __FILE__ == $0
  GEQueue = ARGV.first || "short"
  while true
    data_sort_by_size.each do |fpath|
      submit_fqdump(fpath, GEQueue) if check_volume
    end
  end
end
