# -*- coding: utf-8 -*-

require "rake"
require "fileutils"

Basedir = "/home/inutano/project/ER"

def next_items
  data_dir = Basedir + "/data"
  sra_files = Dir.glob(data_dir + "/*sra")
  sra_files.sort_by{|f| File.size(f) }
end

def disk_full?
  data_usage = `du /home/inutano/project/ER/data | cut -f 1`.chomp.to_i
  fastq_usage = `du /home/inutano/project/ER/fastq | cut -f 1`.chomp.to_i
  disk_usage = data_usage + fastq_usage
  if fastq_usage > 20_000_000_000 or disk_usage > 40_000_000_000
    true
  end
end

def fastq_dump(sra_file)
  cmd = ""
  cmd << "cd #{Basedir}/data && "
  cmd << "/home/inutano/local/bin/sratoolkit/fastq-dump --split-3 "
  cmd << sra_file
  sh cmd
  FileUtils.mv(Dir.glob(sra_file.gsub(/\.sra$/,"*.fastq")), Basedir + "/fastq")
  FileUtils.rm_f(sra_file)
  puts sra_file.split("/").last + " finished at " + Time.now.to_s
rescue RuntimeError
  FileUtils.mv(sra_file, Basedir + "/fqdumpfailed")
  puts sra_file.split("/").last + " ------FAILED------ " + Time.now.to_s
end

if __FILE__ == $0
  while true
    srafiles = next_items
    fqdump_processes = []
    srafiles.each do |fpath|
      # Wait if disk full
      if disk_full?
        puts "Disk quota nearly exceeded: sleep until anyone is out " + Time.now.to_s
        while disk_full?
          sleep 10
        end
      end
      
      # Wait if num of running processes are >13
      while fqdump_processes.map{|pid_c2| !pid_c2.exited? }.size > 13
        sleep 10
      end
      
      pid_c1 = fork do
        pid_c2 = fork do
          fastq_dump(fpath)
        end
        fqdump_processes << pid_c2
      end
      Process.waitpid(pid_c1)
    end
  end
end
