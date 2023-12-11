require 'json'

MyApp.add_route('POST', '/api/v1/puppetfile-check', {
  "resourcePath"  => "/Puppetfile",
  "summary"       => "Upload a Puppetfile and check file",
  "nickname"      => "check_puppet_file",
  "responseClass" => "void",
  "endpoint"      => "/puppetfile-check",
  "notes"         => "Check a Puppetfile for deprecated modules or outdated modules",
  "parameters"    => [
    {
      "name"        => "upload",
      "description" => "Puppet file to upload",
      "dataType"    => "file",
      "paramType"   => "formData",
    },
    {
      "name"        => "exclude",
      "description" => "Comma separated list of modules to exclude",
      "dataType"    => "string",
      "paramType"   => "formData",
    },
    {
      "name"        => "update",
      "description" => "Create an updated Puppet file",
      "dataType"    => "boolean",
      "paramType"   => "formData",
    }
  ] }) do
  cross_origin

  begin
    self.headers "Content-Type" => "application/zip"

    params[:exclude] ? exclude = params[:exclude] : exclude = ''
    params[:update] ? update = params[:update] : update = false

    if params[:upload]
      filename = params[:upload][:filename]
      tempfile = params[:upload][:tempfile]

      pfobj = PuppetFileCheck.new(filename, tempfile, exclude, update)
      pfobj.analyse
      data = pfobj.create_zip

      self.content_type 'application/zip'
      self.attachment "puppetfile-checker.zip"
      self.status 200
      data
    else
      self.status 406
      { "status" => 406, "message" => "File to upload is missing" }.to_json
    end

  rescue Exception => e
    self.status 405
    { "status" => 405, "message" => e.message }.to_json
  end

end

MyApp.add_route('OPTIONS', '/api/v1/puppetfile-check', {
  "resourcePath"  => "/Puppetfile",
  "summary"       => "Upload a Puppetfile and check file",
  "nickname"      => "coption_puppet_file",
  "responseClass" => "void",
  "endpoint"      => "/puppetfile-check",
  "notes"         => "Check a Puppetfile for deprecated modules or outdated modules",
  "parameters"    => [
  ] }) do
  cross_origin

  self.status 200

end
