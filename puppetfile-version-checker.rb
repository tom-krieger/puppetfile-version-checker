#!/usr/bin/env ruby
#
# @author Thomas Krieger

$LOAD_PATH << File.expand_path(File.dirname(__FILE__))

require 'httparty'
require 'optparse'
require 'ostruct'
require 'yaml'
require 'forge_client'
require 'option_parser'
require 'utilities'
require 'gitlab_client'
require 'classes/gitlab'
require 'pp'

# parse commandline options
options = OptionParser.parse(ARGV, 'puppet')

# check commandline options
if options.puppetfile == ''
  puts 'No Puppetfile to analyze!'
  exit 1
end

if options.reportfile == ''
  fh = nil
else
  fh = File.open(options.reportfile, 'w')
end

if options.noforge && !options.gitlab
  puts "You need to use either Puppet Forge, Gitlab or both for module checks."
  exit 1
end

if options.update && options.output == ''
  puts "Update option requires a file to write the changes into."
  exit 1
elsif options.update
  fhupd = File.open(options.output, 'w')
else
  fhupd = nil
end

# write header of report
Utilities.write_report_header(fh, options)

# read all gitlab projects for speeding up work later on
if options.gitlab
  puts "Reading all Gitlab projects ..." if options.verbose
  gitlabObj = Gitlab.new(options.gitlab_url, options.access_token)
  puts "Finished reading all Gitlab projects ..." if options.verbose
end

# initializing what we need
cnt_new        = 0
cnt_deprecated = 0
repo           = ""
project        = ""
tag            = ""
tagline        = ""
in_mod         = false
mod            = ""
modbuffer      = []

# read whole Puppetfile
puts "Reading Puppetfile ..." if options.verbose
filecontent = File.readlines(options.puppetfile)

# loop through Puppetfile content
puts "Analyzing Puppetfile ..." if options.verbose
filecontent.each do |line|
  lineout = line
  line    = line.strip
  ident   = Utilities.get_first_char(lineout)

  if in_mod
    if line =~ %r{^\:git\s*=>}
      modbuffer.push(lineout)
    elsif line =~ %r{^\:tag\s*=>}
      modbuffer.push(lineout)
    elsif line =~ %r{^\:ref\s*=>}
      modbuffer.push(lineout)
    elsif line =~ %r{^\:branch\s*=>}
      modbuffer.push(lineout)
    elsif line =~ %r{^\:install_path\s*=>}
      modbuffer.push(lineout)
    else
      in_mod  = false
      ret     = Utilities.write_mod_buffer(modbuffer, options, fh, fhupd, gitlabObj)
      mod     = ret['mod']
      project = ret['project']
      ident   = ret['ident']
      repo    = ret['repo']
      tag     = ret['tag']
      tagline = ret['tagline']
      cnt_new = cnt_new + ret['cnt_new']
      cnt_deprecated = cnt_deprecated + ret['cnt_deprecated']

      # if !repo.empty? && !tag.empty? && !project.empty? && options.gitlab
      #   counter        = Utilities.work_with_git_line(tagline, mod, project, repo, tag, options, fh, fhupd, gitlabObj, ident)
      #   cnt_new        = cnt_new + counter['new']
      #   cnt_deprecated = cnt_deprecated + counter['deprecated']
      # end

      modbuffer = []

    end

  end

  if line =~ %r{^mod.*["'](.*).*["'].*,.*(["']\d\.\d\.\d["']|:latest)}
    # forge module
    counter        = Utilities.work_with_line(lineout, options, fh, fhupd)
    cnt_new        = cnt_new + counter['new']
    cnt_deprecated = cnt_deprecated + counter['deprecated']

  elsif line =~ %r{^mod.*,$}
    # git module
    in_mod = true
    modbuffer.push(lineout)

  else
    # the rest :)
    unless in_mod
      Utilities.write_update(fhupd, lineout)
    end

  end

end

# if there's a buffer left write it to the files
unless modbuffer.empty?
  ret     = Utilities.write_mod_buffer(modbuffer, options, fh, fhupd, gitlabObj)
  mod     = ret['mod']
  project = ret['project']
  ident   = ret['ident']
  repo    = ret['repo']
  tag     = ret['tag']
  tagline = ret['tagline']
  cnt_new = cnt_new + ret['cnt_new']
  cnt_deprecated = cnt_deprecated + ret['cnt_deprecated']

  # if !repo.empty? && !tag.empty? && !project.empty? && options.gitlab
  #   counter        = Utilities.work_with_git_line(tagline, mod, project, repo, tag, options, fh, fhupd, gitlabObj, ident)
  #   cnt_new        = cnt_new + counter['new']
  #   cnt_deprecated = cnt_deprecated + counter['deprecated']
  # end
end

# write report footer
puts "Finishing report ..." if options.verbose
Utilities.write_report_footer(cnt_new, cnt_deprecated, fh)

# close files
fh.close unless fh.nil?
fhupd.close unless fhupd.nil?

# calculate return code from what happened
ret = Utilities.calculate_return_code(cnt_new, cnt_deprecated)
exit ret
