# :)

PROJ_ROOT = File.expand_path(__dir__)

DATE = Time.now.strftime("%Y%m%d")

MirrorDir = File.join PROJ_ROOT, "mirror"
FastqDir  = File.join PROJ_ROOT, "fastq"
ResultDir = File.join PROJ_ROOT, "result"
TableDir  = File.join PROJ_ROOT, "tables", DATE

NUM_OF_PARALLEL = 8

Dir["#{PROJ_ROOT}/lib/tasks/**/*.rake"].each do |path|
  load path
end
