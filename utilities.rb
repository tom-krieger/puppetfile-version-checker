class Utilities
  # Class with helper methods

  def self.write_line(fh, line)
    # write line to report

    if fh.nil?
      puts line
    else
      fh.write(line)
    end

  end


  def self.write_update(fh, line)
    # write line to updated Puppetfile

    unless fh.nil?
      fh.write(line)
    end

  end


  def self.work_with_line(line, options, fh, fhupd)
    # analyse line

    counter        = {}
    cnt_new        = 0
    cnt_deprecated = 0
    lineFormat     = create_report_format_string(options)

    if line =~ %r{:latest$}
      m = line.match(%r{^mod.*["'](?<mod>.*).*["'].*,.*(?<version>:latest)})
    else
      m = line.match(%r{^mod.*["'](?<mod>.*).*["'].*,.*["'](?<version>\d\.\d\.\d)["']})
    end

    mod  = m[:mod].sub('/', '-')
    vers = m[:version]
    if options.noforge
      cur_version = 'n/a'
      deprecated  = 'no'
    else
      data        = ForgeClient.get_current_module_data(mod)
      cur_version = data[:version]
      deprecated  = data[:deprecated]
    end

    if deprecated == 'yes'
      msg            = 'deprecated!'
      cnt_deprecated = 1
      unless options.exclude.include?(mod)
        self.write_update(fhupd, "# module deprecated\n")
        self.write_update(fhupd, "# #{line}")
      else
        self.write_update(fhupd, line)
      end
    elsif (cur_version == 'n/a')
      msg = ''
      self.write_update(fhupd, line)
    elsif (vers != cur_version) && (vers != ':latest')
      msg     = 'new version available'
      cnt_new = 1
      unless options.exclude.include?(mod)
        self.write_update(fhupd, line.sub(vers, cur_version))
      else
        self.write_update(fhupd, line)
      end
    else
      msg = ''
      self.write_update(fhupd, line)
    end

    unless options.noforge
      args = []
      args.push(mod)
      args.push(vers)
      unless options.noforge
        args.push(cur_version)
      end
      if options.gitlab
        args.push(' ')
      end
      args.push(msg)

      self.write_line(fh, sprintf(lineFormat, *args))
    end

    counter['new']        = cnt_new
    counter['deprecated'] = cnt_deprecated
    counter
  end


  def self.work_with_git_line(tagline, mod, project, repo, vers, options, fh, obj, ident)
    # work with a Gitlab module

    counter        = {}
    cnt_new        = 0
    cnt_deprecated = 0
    lineFormat     = create_report_format_string(options)
    repo_id        = obj.get_repo_id_by_name("#{project}/#{repo}")
    if repo_id.empty?
      cur_version = 'n/a'
    else
      cur_version = obj.get_highest_tag(repo_id)
    end

    if (vers != cur_version) && (vers != ':latest')
      msg        = 'new version available'
      cnt_new    = 1

      unless options.exclude.include?(mod)
        taglineout = tagline.sub(vers, cur_version)
      else
        taglineout = tagline
      end
      str        = " " * ident
      taglineout = "#{str}#{taglineout}"
      # self.write_update(fhupd, "#{taglineout}\n")
    else
      msg = ''
    end

    args = []
    args.push(mod)
    args.push(vers)
    unless options.noforge
      args.push(' ')
    end
    args.push(cur_version)
    args.push(msg)

    self.write_line(fh, sprintf(lineFormat, *args))

    ret                   = {}
    counter['new']        = cnt_new
    counter['deprecated'] = cnt_deprecated
    ret['counter']        = counter
    ret['line']           = "#{taglineout}\n"
    ret
  end


  def self.get_first_char(str)
    # get first non blank character to determine ident of Puppetfile

    cnt = 0
    while str[cnt, 1] == ' ' do
      cnt += 1
    end
    cnt
  end


  def self.calculate_return_code(cnt_new, cnt_deprecated)
    # calculate return code

    ret = 0
    if cnt_deprecated >= 0 && cnt_new >= 0
      ret = 5
    elsif cnt_deprecated > 0
      ret = 3
    elsif cnt_new > 0
      ret = 4
    end

    ret
  end


  def self.create_report_format_string(options)
    # create a sprint format string

    headerFormat = "%-50s %10s"

    unless options.noforge
      headerFormat = "#{headerFormat} %10s"
    end

    if options.gitlab
      headerFormat = "#{headerFormat} %10s"
    end

    headerFormat = "#{headerFormat} %s\n"

    headerFormat
  end


  def self.write_report_header(fh, options)
    # write the report header

    header1Text = [' ', 'Puppetfile']
    header2Text = ['Module slug', 'Version']
    header3Text = %w[-------------------------------------------------- ----------]

    unless options.noforge
      header1Text.push('Forge')
      header2Text.push('Version')
      header3Text.push('----------')
    end

    if options.gitlab
      header1Text.push('Gitlab')
      header2Text.push('Version')
      header3Text.push('----------')
    end

    header1Text.push(' ')
    header2Text.push('Comment')
    header3Text.push('--------------------')

    headerFormat = create_report_format_string(options)

    write_line(fh, sprintf(headerFormat, *header1Text))
    write_line(fh, sprintf(headerFormat, *header2Text))
    write_line(fh, sprintf(headerFormat, *header3Text))
  end


  def self.write_report_footer(cnt_new, cnt_deprecated, fh)
    # write the report footr

    write_line(fh, "\n\n")
    write_line(fh, "Puppetfile summary:\n")
    write_line(fh, sprintf("%5d modules with newer versions available at Puppet Forge\n", cnt_new))
    write_line(fh, sprintf("%5d modules are deprecated\n", cnt_deprecated))
    write_line(fh, "\n")
  end


  def self.write_mod_buffer(modbuffer, options, fh, fhupd, gitlabObj)
    # write buffered content to report and files

    repo           = ""
    tag            = ""
    project        = ""
    tagline        = ""
    mod            = ""
    ident          = 0
    output         = []
    cnt_new        = 0
    cnt_deprecated = 0

    modbuffer.each do |line_buf|
      lineout_buf = line_buf
      line_buf    = line_buf.strip

      if line_buf =~ %r{^\:git\s*=>.*http}
        match   = line_buf.match(%r{\/\/(?<server>[a-zA-Z0-9_\-\.\:]*)\/(?<project>[a-zA-Z0-9_\-\.]*)\/(?<repo>[a-zA-Z0-9_\-\.]*)\.git})
        repo    = match[:repo]
        project = match[:project]
        output.push(lineout_buf)

      elsif line_buf =~ %r{^\:git\s*=>}
        match   = line_buf.match(%r{(?<user>[a-zA-Z0-9\-_]*)\@(?<server>[0-9A-Za-z_\-\.\:]*)\/(?<project>[a-zA-Z0-9_\-\.]*)\/(?<repo>[a-zA-Z0-9_\-\.]*)\.git})
        repo    = match[:repo]
        project = match[:project]
        output.push(lineout_buf)

      elsif line_buf =~ %r{^\:(branch|ref|install_path)}
        output.push(lineout_buf)

      elsif line_buf =~ %r{^\:tag\s*=>}
        ident   = Utilities.get_first_char(lineout_buf)
        match   = line_buf.match(%r{^:tag\s*=>\s*[\'\"](?<tag>.*)[\'\"]})
        tag     = match[:tag]
        tagline = line_buf

      elsif line_buf =~ %r{^mod.*,}
        m   = line_buf.match(%r{^mod.*["'](?<mod>.*).*["']})
        mod = m[:mod].sub('/', '-')
        output.push(lineout_buf)
      end
    end

    if !repo.empty? && !tag.empty? && !project.empty? && options.gitlab
      data           = Utilities.work_with_git_line(tagline, mod, project, repo, tag, options, fh, gitlabObj, ident)
      counter        = data['counter']
      out_line       = data['line']
      cnt_new        = cnt_new + counter['new']
      cnt_deprecated = cnt_deprecated + counter['deprecated']
      output.push(out_line)
    end

    write_sorted_output(output, fhupd)

    ret                   = {}
    ret['mod']            = mod
    ret['project']        = project
    ret['ident']          = ident
    ret['repo']           = repo
    ret['tag']            = tag
    ret['tagline']        = tagline
    ret['cnt_new']        = cnt_new
    ret['cnt_deprecated'] = cnt_deprecated

    ret
  end


  private


  def self.write_sorted_output(output, fhupd)
    output.each do |out|
      unless out =~ %r{,$}
        output.delete_at(output.index(out))
        output.push(out)
      end
    end

    output.each do |line|
      Utilities.write_update(fhupd, line)
    end
  end

end