# -*- coding: utf-8 -*-

require "fileutils"

BASE = "/home/inutano"
PROJ_BASE = File.join(BASE, "project/ER")

def disk_full?
  data_usage = `du /home/inutano/project/ER/data 2> /dev/null | cut -f 1`.chomp.to_i
  fastq_usage = `du /home/inutano/project/ER/fastq 2> /dev/null | cut -f 1`.chomp.to_i
  disk_usage = data_usage + fastq_usage
  data_usage > 20_000_000_000 or disk_usage > 40_000_000_000
end

def wd
  { download_dir:      PROJ_BASE + "/download",
    download_log:      PROJ_BASE + "/table/download_log",
    download_notfound: PROJ_BASE + "/table/download_notfound",
    data_dir:          PROJ_BASE + "/data",
    fastq_dir:         PROJ_BASE + "/fastq" }
end

def file_transfer(fpath)
  fname = fpath.split("/").last
  FileUtils.cp(fpath, wd[:download_dir])
  target_dir = case fname
               when /sra$/
                 File.join(wd[:data_dir], fname.gsub(/...\.sra$/,""))
               when /bz2$/
                 wd[:fastq_dir]
               else
                 wd[:data_dir]
               end
  FileUtils.mkdir(target_dir) if !File.exist?(target_dir)
  FileUtils.mv(File.join(wd[:download_dir], fname), target_dir)
  open(wd[:download_log],"a"){|f| f.puts(fname) }
rescue Errno::ENOENT
  open(wd[:download_notfound],"a"){|f| f.puts(fpath+"\tnot found") }
rescue Errno::EISDIR
  open(wd[:download_notfound],"a"){|f| f.puts(fpath+"\tcontains directory") }
end

if __FILE__ == $0
  filelist_path = ARGV.first || PROJ_BASE + "/table/filelist"
  filelist = open(filelist_path).readlines
  
  progress = 0
  while !filelist.empty?
    if disk_full?
      puts "Disk quota nearly exceeded: sleep until anyone is out " + Time.now.to_s
      while disk_full?
        sleep 10
      end
    end
    
    simultaneous_proc = 25
    download = filelist.shift(simultaneous_proc).map{|l| l.chomp }
    
    threads = []
    download.flatten.each do |fpath|
      th = Thread.new do
        file_transfer(fpath)
      end
      threads << th
    end
    threads.each{|th| th.join }
    
    progress += simultaneous_proc
    puts "#{Time.now}\t" + progress.to_s + " files transferred, " + filelist.size.to_s + " files left"
  end
end
