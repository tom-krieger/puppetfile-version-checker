# frozen_string_literal: true

class PuppetFileCheck
  attr_accessor :upload, :tempfile, :exclude, :update, :puppetfile
  attr_reader :local_report, :local_puppetfile, :local_zipfile


  def initialize(upload, tempfile, exclude, update)
    @upload           = upload
    @tempfile         = tempfile
    @exclude          = exclude
    if update == 'false'
      @update = false
    elsif update == 'true'
      @update = true
    else
      @update = false
    end
    @local_report     = Tempfile.create('report', './work', autoclose: false, autodelete: false)
    @local_puppetfile = Tempfile.create('Puppetfile', './work', autoclose: false, autodelete: false)
    @puppetfile       = tempfile.readlines
  end


  def analyse
    Utilities.write_line(@local_report, sprintf("%-50s %10s %10s %s\n", ' ',
                                                'Puppetfile', 'Forge', ''))
    Utilities.write_line(@local_report, sprintf("%-50s %10s %10s %s\n",
                                                'Module slug', 'Version', 'Version', 'Comment'))
    Utilities.write_line(@local_report, sprintf("%-50s %10s %10s %s\n",
                                                '--------------------------------------------------', '----------',
                                                '----------', '--------------------'))
    options         = OpenStruct.new
    options.exclude = @exclude.split(',')
    cnt_new         = 0
    cnt_deprecated  = 0
    line_continued  = 0
    filecontent     = @puppetfile
    filecontent.each do |line|

      line.strip!
      if line =~ %r{^mod.*["'](.*).*["'].*,.*(["']\d\.\d\.\d["']|:latest)}

        counter        = Utilities.work_with_line(line, options, @local_report, @local_puppetfile)
        cnt_new        = cnt_new + counter['new']
        cnt_deprecated = cnt_deprecated + counter['deprecated']

      elsif line =~ %r{,$}
        puts "Komma"
      else
        Utilities.write_update(@local_puppetfile, line)
      end

    end

    Utilities.write_report_footer(cnt_new, cnt_deprecated, @local_report)
  end


  def create_zip
    @local_report.rewind
    @local_puppetfile.rewind

    stringio = Zip::OutputStream::write_buffer do |zio|
      if @update
        zio.put_next_entry("Puppetfile")
        zio.write(@local_puppetfile.read)
      end
      zio.put_next_entry("report.txt")
      zio.write(@local_report.read)
    end

    cleanup

    stringio.rewind
    data = stringio.sysread
    data
  end


  private


  def cleanup
    File.delete(@local_puppetfile.path) if File.exist?(@local_puppetfile.path)
    File.delete(@local_report.path) if File.exist?(@local_report.path)
  end
end
