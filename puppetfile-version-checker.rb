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

Utilities.write_line(fh, sprintf("%-40s %10s %10s %s\n", ' ',
                                 'Puppetfile', 'Forge', ''))
Utilities.write_line(fh, sprintf("%-40s %10s %10s %s\n",
                                 'Module slug', 'Version', 'Version', 'Comment'))
Utilities.write_line(fh, sprintf("%-40s %10s %10s %s\n",
                                 '----------------------------------------', '----------',
                                 '----------', '--------------------'))

cnt_new        = 0
cnt_deprecated = 0
filecontent    = File.readlines(options.puppetfile)
filecontent.each do |line|

  if line =~ %r{^mod.*(\"|\')(.*).*(\"|\').*,.*(\"|\')\d\.\d\.\d(\"|\')}

    m           = line.match(%r{^mod.*(\"|\')(?<mod>.*).*(\"|\').*,.*(\"|\')(?<version>\d\.\d\.\d)(\"|\')})
    mod         = m[:mod].sub('/', '-')
    vers        = m[:version]
    data        = ForgeClient.get_current_module_data(mod)
    cur_version = data[:version]
    deprecated  = data[:deprecated]

    if deprecated == 'yes'
      msg            = 'deprecated!'
      cnt_deprecated = cnt_deprecated + 1
      unless options.exclude.include?(mod)
        Utilities.write_update(fhupd, "# module deprecated\n")
        Utilities.write_update(fhupd, "# #{line}")
      else
        Utilities.write_update(fhupd, line)
      end
    elsif vers != cur_version
      msg     = 'new version available'
      cnt_new = cnt_new + 1
      unless options.exclude.include?(mod)
        Utilities.write_update(fhupd, line.sub(vers, cur_version))
      else
        Utilities.write_update(fhupd, line)
      end
    else
      msg = ''
      Utilities.write_update(fhupd, line)
    end

    Utilities.write_line(fh, sprintf("%-40s %10s %10s %s\n", mod, vers, cur_version, msg))

  else
    Utilities.write_update(fhupd, line)
  end

end

Utilities.write_line(fh, "\n\n")
Utilities.write_line(fh, "Puppetfile summary:\n")
Utilities.write_line(fh, sprintf("%5d modules with newer versions available at Puppet Forge\n", cnt_new))
Utilities.write_line(fh, sprintf("%5d modules are deprecated\n", cnt_deprecated))
Utilities.write_line(fh, "\n")

fh.close unless fh.nil?
fhupd.close unless fhupd.nil?

if cnt_deprecated >= 0 && cnt_new >= 0
  exit 5
elsif cnt_deprecated > 0
  exit 3
elsif cnt_new > 0
  exit 4
else
  exit 0
end
