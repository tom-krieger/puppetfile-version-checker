class Utilities

  def self.writeLine(fh, line)

    if fh.nil? then
      puts line
    else
      fh.write(line)
    end

  end

  def self.writeUpdate(fh, line)

    if !fh.nil? then
      fh.write(line)
    end

  end

end