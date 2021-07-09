class Utilities

  # write line to report
  def self.write_line(fh, line)

    if fh.nil?
      puts line
    else
      fh.write(line)
    end

  end


  # write line to updated Puppetfile
  def self.write_update(fh, line)

    unless fh.nil?
      fh.write(line)
    end

  end


  # analyse line
  def self.work_with_line(line, options, fh, fhupd)
    counter        = {}
    cnt_new        = 0
    cnt_deprecated = 0

    if line =~ %r{:latest$}
      m = line.match(%r{^mod.*["'](?<mod>.*).*["'].*,.*(?<version>:latest)})
    else
      m = line.match(%r{^mod.*["'](?<mod>.*).*["'].*,.*["'](?<version>\d\.\d\.\d)["']})
    end

    mod         = m[:mod].sub('/', '-')
    vers        = m[:version]
    data        = ForgeClient.get_current_module_data(mod)
    cur_version = data[:version]
    deprecated  = data[:deprecated]

    if deprecated == 'yes'
      msg            = 'deprecated!'
      cnt_deprecated = 1
      unless options.exclude.include?(mod)
        Utilities.write_update(fhupd, "# module deprecated\n")
        Utilities.write_update(fhupd, "# #{line}")
      else
        Utilities.write_update(fhupd, line)
      end
    elsif (vers != cur_version) && (vers != ':latest')
      msg     = 'new version available'
      cnt_new = 1
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

    counter['new']        = cnt_new
    counter['deprecated'] = cnt_deprecated
    counter
  end


  def self.calculate_return_code(cnt_new, cnt_deprecated)

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


  def self.write_report_footer(cnt_new, cnt_deprecated, fh)
    write_line(fh, "\n\n")
    write_line(fh, "Puppetfile summary:\n")
    write_line(fh, sprintf("%5d modules with newer versions available at Puppet Forge\n", cnt_new))
    write_line(fh, sprintf("%5d modules are deprecated\n", cnt_deprecated))
    write_line(fh, "\n")
  end

end