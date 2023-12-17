# frozen_string_literal: true

class GitlabClient
  # Helper functions to access Gitlab and get all projects and all tags for a
  # particular repository. The functions are able to use pagination.
  #
  # @author Thomas Krieger

  include HTTParty

  # @!attribute token Gitlab token
  # @!attribute api_version Gitlab API version
  attr_reader :token, :api_version

  gitlab_url         = ''
  gitlab_api_version = 'v4'
  proxy_url          = ''
  proxy_port         = ''
  proxy_user         = ''
  proxy_pass         = ''
  token              = ''

  if File.exist?("config.yaml")
    config = YAML.load_file('config.yaml')
    if config.key?('gitlab')
      gitlab             = config['gitlab']
      gitlab_url         = gitlab.key?('api_url') ? gitlab['api_url'] : 'https://localhost'
      gitlab_api_version = gitlab.key?('api_version') ? gitlab['api_version'] : 'v4'
      token              = gitlab.key?('token') ? gitlab['token'] : ''
      proxy_url          = gitlab.key?('proxy_url') ? gitlab['proxy_url'] : ''
      proxy_port         = gitlab.key?('proxy_port') ? gitlab['proxy_port'] : ''
      proxy_user         = gitlab.key?('proxy_user') ? gitlab['proxy_user'] : ''
      proxy_pass         = gitlab.key?('proxy_pass') ? gitlab['proxy_pass'] : ''
    end
  end

  @token       = token
  @api_version = gitlab_api_version

  base_uri gitlab_url

  if proxy_url != ''
    if proxy_user != ''
      http_proxy proxy_url, proxy_port, proxy_user, proxy_pass
    else
      http_proxy proxy_url, proxy_port
    end
  end


  def self.get_projects(uri)
    # get_projects
    # read all projects from Gitlab and use pagination if there are mote than 100 projects
    ret      = {}
    cache    = {}
    headers  = { "PRIVATE-TOKEN" => @token }
    response = get(uri, :headers => headers)
    case response.code
    when 200..399
      details = JSON.parse(response.body)
      headers = response.headers

      details.each do |detail|
        id               = detail['id']
        name             = detail['name']
        name_path        = detail['path_with_namespace']
        entry            = {
          'name' => name,
          'id'   => id,
        }
        cache[name_path] = entry
      end

      if headers.key?('x-next-page')
        page = headers['x-next-page']
        if page.empty?
          uri = ""
        else
          uri = "/api/#{@api_version}/projects?page=#{page}&per_page=100&order_by=id&sort=asc"
        end

      elsif headers.key?('link')
        link     = headers['link']
        m        = link.match(%r{id_after=(?<id_after>\d*)})
        id_after = m[:id_after]
        uri      = "/api/#{@api_version}/projects?id_after=#{id_after}&per_page=100&order_by=id&sort=asc"
      else
        uri = ''
      end
    else
      cache = {}
      uri   = ''
    end

    ret['cache'] = cache.to_json
    ret['uri']   = uri

    ret
  end


  def self.get_repository_tags(uri)
    # get_repository_tags
    # read all tags for a particular repository

    ret      = {}
    tags     = []
    headers  = { "PRIVATE-TOKEN" => @token }
    response = get(uri, :headers => headers)
    case response.code
    when 200..399
      details = JSON.parse(response.body)
      headers = response.headers

      details.each do |detail|
        if detail.key?('name')
          tags.push(detail['name'])
        end
      end

      uri = ''
    else
      tags = []
      uri  = ''
    end

    ret['tags'] = tags.to_json
    ret['uri']  = uri

    ret
  end
end
