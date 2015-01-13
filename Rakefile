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
