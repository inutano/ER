# :)

namespace :setup do
  desc "Trigger task to prepara directories and files"
  task :init => [MirrorDir, FastqDir, ResultDir, TableDir, "SRA_Accessions.tab", "mirror.log"] do
    puts "completed."
  end
  
  task :update => [TableDir, "SRA_Accessions.tab"] do
    puts "completed."
  end
  
  directory MirrorDir
  directory FastqDir
  directory ResultDir
  directory TableDir
  
  file "mirror.log" => TableDir do |t|
    cd TableDir
    touch t.to_s
  end
  
  sra_accessions_table_fname = "SRA_Accessions.tab"
  file sra_accessions_table_fname => TableDir do |t|
    sh "lftp -c \"open ftp.ncbi.nlm.nih.gov/sra/reports/Metadata && pget -n 8 -O #{TableDir} #{t.to_s}\""
  end
end
