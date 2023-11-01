class OptionParser

  def self.parse_puppet(args)
    options            = OpenStruct.new
    options.puppetfile = ''
    options.reportfile = ''
    options.update     = false
    options.output     = ''
    options.exclude    = []

    opt_parser = OptionParser.new do |opts|

      opts.on("-p", "--puppetfile PUPPETFILE", "Puppetfile to read with full path") do |puppetfile|
        options.puppetfile = puppetfile || ''
      end

      opts.on("-r", "--report REPORTFILE", "File to write report in (optional)") do |reportfile|
        options.reportfile = reportfile || ''
      end

      opts.on("-o", "--output OUTPUTFILE", "File to write new Puppetfile content (required with -u)") do |outputfile|
        options.output = outputfile || ''
      end

      opts.on("-e", "--exclude MODULESLUG", "Modules to be excluded") do |exclude|
        options.exclude.push(exclude)
      end

      opts.on("-u", "--update", "Create updated Puppetfile (optional)") do |v|
        options.update = v
      end

      opts.on_tail("-h", "--help", "Show this message") do
        exit 1
      end
    end

    begin
      opt_parser.parse!(args)
      options
    rescue Exception => e
      puts
      puts e.message
      puts
      puts opt_parser
      puts
      exit 1
    end
  end

  def self.parse_fixture(args)
    options            = OpenStruct.new
    options.fixturesfile = ''

    opt_parser = OptionParser.new do |opts|

      opts.on("-f", "--fixturesfile FIXTURESFILE", "Fixtures file to read with full path") do |fixturesfile|
        options.fixturesfile = fixturesfile || ''
      end

      opts.on_tail("-h", "--help", "Show this message") do
        exit 1
      end
    end

    begin
      opt_parser.parse!(args)
      options
    rescue Exception => e
      puts
      puts e.message
      puts
      puts opt_parser
      puts
      exit 1
    end
  end

  def self.parse(args, type='puppet')
    if type == 'puppet'
      ret = self.parse_puppet(args)
    elsif type == 'fixtures'
      ret = self.parse_fixture(args)
    else
      ret = nil
    end

    ret
  end
end