$LOAD_PATH << File.expand_path(File.dirname(__FILE__))

require 'httparty'
require 'optparse'
require 'ostruct'
require 'forge_client'


def writeLine(fh, line)

  if fh.nil? then
    puts line
  else
    fh.write(line)
  end

end


options            = OpenStruct.new
options.puppetfile = ''
options.reportfile = ''

opt_parser = OptionParser.new do |opts|
  opts.on("-p", "--puppetfile PUPPETFILE", "Puppetfile to read with full path") do |puppetfile|
    options.puppetfile = puppetfile || ''
  end

  opts.on("-r", "--report REPORTFILE", "File to write report in (optional)") do |reportfile|
    options.reportfile = reportfile || ''
  end

  # No argument, shows at tail.  This will print an options summary.
  # Try it and see!
  opts.on_tail("-h", "--help", "Show this message") do
    puts opts
    exit
  end
end

begin
  opt_parser.parse!(ARGV)
rescue Exception => e
  puts
  puts e
  puts
  puts opt_parser
  exit 2
end

if options.puppetfile == '' then
  puts 'No Puppetfile to analyze!'
  exit 1
end

if options.reportfile == '' then
  fh = nil
else
  fh = File.open(options.reportfile, 'w')
end

writeLine(fh, sprintf("%-40s %10s %10s %s\n", ' ', 'Puppetfile', 'Forge', ''))
writeLine(fh, sprintf("%-40s %10s %10s %s\n", 'Module slug', 'Version', 'Version', 'Comment'))
writeLine(fh, sprintf("%-40s %10s %10s %s\n", '----------------------------------------',
                      '----------', '----------', '--------------------'))

cntNew        = 0
cntDeprecated = 0
filecontent   = File.readlines(options.puppetfile)
filecontent.each do |line|

  if line =~ %r{^mod.*(\"|\')(.*).*(\"|\').*,.*(\"|\')\d\.\d\.\d(\"|\')} then

    m           = line.match(%r{^mod.*(\"|\')(?<mod>.*).*(\"|\').*,.*(\"|\')(?<version>\d\.\d\.\d)(\"|\')})
    mod         = m[:mod].sub('/', '-')
    vers        = m[:version]
    data        = ForgeClient.get_current_module_data(mod)
    cur_version = data[:version]
    deprecated  = data[:deprecated]

    if deprecated == 'yes' then
      msg           = 'deprecated!'
      cntDeprecated = cntDeprecated + 1
    elsif vers != cur_version then
      msg    = 'new version available'
      cntNew = cntNew + 1
    else
      msg = ''
    end

    writeLine(fh, sprintf("%-40s %10s %10s %s\n", mod, vers, cur_version, msg))
  end
end

writeLine(fh, "\n\n")
writeLine(fh, "Puppetfile summary:\n")
writeLine(fh, sprintf("%5d modules with newer versions available at Puppet Forge\n", cntNew))
writeLine(fh, sprintf("%5d modules are deprecated\n", cntDeprecated))
writeLine(fh, "\n")

fh.close() if !fh.nil?

exit 0
