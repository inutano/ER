# :)

require 'parallel'

namespace :filelist do
  desc "Create filelist based on the SRA filelist and local results"
  task :create do
  end
  
  def live_list
    # Field 0: Accession ID, 1: Submission ID, 4: Status, 10: Visibility, 12: Experiment ID
    array = []
    open(File.join(TableDir, "SRA_Accessions.tab")).each do |line|
      l = line.split("\t")
      if l[0] =~ /^.RR/ && l[4] == "live" && l[10] == "public"
        array << {
                   id: l[0],
                   submission: l[1],
                   experiment: l[12]
                 }
      end
    end
    array
  end
  
  def items_done
    m = "message here"
    Parallel.map(Dir.glob(ResultDir + "/*RR*"), :in_threads => NUM_OF_PARALLEL, :progress => m) do |p_dir|
      Dir.glob(p_dir + "/*RR*").map do |id_dir|
        zipfiles = Dir.glob(id_dir + "/*zip")
        zipfile.map{|f| { :path => f, :size => File.size(f) } } if !zipfile.empty?
      end
    end
  end
  
  def items_undone
  end
  
  def get_filepath
  end
end



class SRAFile
  HOME = "/home/inutano"
  ACC = HOME + "/project/ER/table/SRA_Accessions.tab"
  @@hash = {}
  @@num_of_parallel = 16
  
  def self.set_accessions_hash
    s = `awk -F '\t' '$1 ~ /^.RR/ && $3 == "live" && $9 == "public" { print $1 "\t" $2 "\t" $11 }' #{ACC}`
    s.split("\n").each do |str|
      a = str.split("\t")
      @@hash[a[0]] = [a[1], a[2]]
    end
  end

  def self.available_list
    s = `awk -F '\t' '$1 ~ /^.RR/ && $3 == "live" && $9 == "public" { print $1 }' #{ACC}`
    s.split("\n").sort
  end
  
  def self.qc_done_list
    # return an array of qc-done ID
    fastqc_result_dir = HOME + "/backup/fastqc_result"
    index_dirs = Dir.glob(fastqc_result_dir + "/*RR*")
    runid_dirs = Parallel.map(index_dirs, :in_threads => @@num_of_parallel){|dpath| Dir.glob("#{dpath}/*RR*") }.flatten
    runfiles = Parallel.map(runid_dirs, :in_threads => @@num_of_parallel){|dpath| Dir.glob("#{dpath}/*zip") }.flatten
    Parallel.map(runfiles, :in_threads => @@num_of_parallel){|fname| fname.split("/").last.slice(0..8) }.sort.uniq
  end
  
  def self.fq_path(id)
    # return an array of fastq file path and filesize
    v = @@hash[id]
    fq_path = File.join(HOME, "data/fastq_data", v[0].slice(0..5), v[0], v[1])
    if File.exist?(fq_path)
      fq_files_path = Dir.glob(fq_path + "/#{id}*")
      if !fq_files_path.empty?
        fq_files_path.map{|f| [f, File.size(f)] }
      end
    end
  end
  
  def self.sra_path(id)
    # return an array of sra file and filesize
    v = @@hash[id]
    wtf = "data/litesra_data/ByExp/litesra"
    sralite_path = File.join(HOME, wtf, v[1].slice(0..2), v[1].slice(0..5), v[1], id)
    if File.exist?(sralite_path)
      sralite_file = Dir.glob(sralite_path + "/#{id}*sra")
      if !sralite_file.empty?
        sralite_file.map{|f| [f, File.size(f)] }
      end
    end
  end
  
  def self.get_file_path(id)
    path_array = self.fq_path(id)
    if !path_array
      path_array = self.sra_path(id)
    end
    path_array
  end
  
  def self.sorted_filepath(id_array)
    file_path_array = Parallel.map(id_array, :in_threads => @@num_of_parallel){|id| self.get_file_path(id) }.compact
    box_to_sort = []
    file_path_array.each do |path_array|
      path_array.each do |path_size|
        box_to_sort << path_size
      end
    end
    box_to_sort.sort_by{|array| array[1] }.map{|array| array.first }
  end
end

if __FILE__ == $0
  available_id = SRAFile.available_list
  qc_done_id = SRAFile.qc_done_list
  waiting_id = available_id - qc_done_id
  SRAFile.set_accessions_hash
  puts SRAFile.sorted_filepath(waiting_id)
end
