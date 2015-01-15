# :)

namespace :setup do
  desc "Trigger task to prepara directories and files"
  task :init => ["data", "fastqc", "fqdumpfailed", "table", "download_log"] do
    puts "completed."
  end
  
  directory "data"
  directory "fastqc"
  directory "fqdumpfailed"
  directory "table"
  
  file "download_log" => "table" do |t|
    cd "table"
    touch t.to_s
  end
end

namespace :filelist do
  desc "Create filelist based on the SRA filelist and local results"
  task :create do
  end
end

namespace :update do
  desc "Copy files from maid disc, execute this on the proper node"
  task :file_transfer do
  end
  
  desc "Decompress SRA format data in parallel"
  task :fastq_dump do
  end
  
  desc "Decompress bzip2 format data on GridEngine"
  task :bunzip2 do
  end
  
  desc "Execute FastQC for all the fastq data"
  task :fastqc do
  end
end
