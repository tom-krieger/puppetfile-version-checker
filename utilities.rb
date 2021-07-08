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

end