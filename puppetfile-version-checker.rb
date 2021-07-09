#!/usr/bin/env ruby

$LOAD_PATH << File.expand_path(File.dirname(__FILE__))

require 'httparty'
require 'optparse'
require 'ostruct'
require 'yaml'
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

  if line =~ %r{^mod.*["'](.*).*["'].*,.*(["']\d\.\d\.\d["']|:latest)}

    counter        = Utilities.work_with_line(line, options, fh, fhupd)
    cnt_new        = cnt_new + counter['new']
    cnt_deprecated = cnt_deprecated + counter['deprecated']

  else
    Utilities.write_update(fhupd, line)
  end

end

Utilities.write_report_footer(cnt_new, cnt_deprecated, fh)

fh.close unless fh.nil?
fhupd.close unless fhupd.nil?

ret = Utilities.calculate_return_code(cnt_new, cnt_deprecated)
exit ret
