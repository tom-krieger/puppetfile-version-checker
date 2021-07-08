#!/usr/bin/env ruby

$LOAD_PATH << File.expand_path(File.dirname(__FILE__))

require 'httparty'
require 'optparse'
require 'ostruct'
require 'forge_client'
require 'option_parser'
require 'utilities'

options = OptionParser.parse(ARGV)

if options.puppetfile == ''
  puts 'No Puppetfile to analyze!'
  exit 1
end

if options.reportfile == ''
  fh = nil
else
  fh = File.open(options.reportfile, 'w')
end

if options.update && options.output == ''
  puts "Update option requires a file to write the changes into."
  exit 1
elsif options.update
  fhupd = File.open(options.output, 'w')
else
  fhupd = nil
end

Utilities.writeLine(fh, sprintf("%-40s %10s %10s %s\n", ' ', 'Puppetfile', 'Forge', ''))
Utilities.writeLine(fh, sprintf("%-40s %10s %10s %s\n", 'Module slug', 'Version', 'Version', 'Comment'))
Utilities.writeLine(fh, sprintf("%-40s %10s %10s %s\n", '----------------------------------------',
                                '----------', '----------', '--------------------'))

cntNew        = 0
cntDeprecated = 0
filecontent   = File.readlines(options.puppetfile)
filecontent.each do |line|

  if line =~ %r{^mod.*(\"|\')(.*).*(\"|\').*,.*(\"|\')\d\.\d\.\d(\"|\')}

    m           = line.match(%r{^mod.*(\"|\')(?<mod>.*).*(\"|\').*,.*(\"|\')(?<version>\d\.\d\.\d)(\"|\')})
    mod         = m[:mod].sub('/', '-')
    vers        = m[:version]
    data        = ForgeClient.get_current_module_data(mod)
    cur_version = data[:version]
    deprecated  = data[:deprecated]

    if deprecated == 'yes'
      msg           = 'deprecated!'
      cntDeprecated = cntDeprecated + 1
      Utilities.writeUpdate(fhupd, "# module deprecated\n")
      Utilities.writeUpdate(fhupd, "# #{line}")
    elsif vers != cur_version
      msg    = 'new version available'
      cntNew = cntNew + 1
      Utilities.writeUpdate(fhupd, line.sub(vers, cur_version))
    else
      msg = ''
      Utilities.writeUpdate(fhupd, line)
    end

    Utilities.writeLine(fh, sprintf("%-40s %10s %10s %s\n", mod, vers, cur_version, msg))

  else
    Utilities.writeUpdate(fhupd, line)
  end
end

Utilities.writeLine(fh, "\n\n")
Utilities.writeLine(fh, "Puppetfile summary:\n")
Utilities.writeLine(fh, sprintf("%5d modules with newer versions available at Puppet Forge\n", cntNew))
Utilities.writeLine(fh, sprintf("%5d modules are deprecated\n", cntDeprecated))
Utilities.writeLine(fh, "\n")

fh.close() if !fh.nil?
fhupd.close() if !fhupd.nil?

exit 0
