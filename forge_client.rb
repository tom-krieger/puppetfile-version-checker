class ForgeClient
  include HTTParty

  forge_url  = 'https://forgeapi.puppet.com'
  proxy_url  = ''
  proxy_port = ''
  proxy_user = ''
  proxy_pass = ''

  if File.exist?('config.yaml')

    config = YAML.load_file('config.yaml')
    if config.key?('forge')
      forge      = config['forge']
      forge_url  = forge.key?('url') ? forge['url'] : 'https://forgeapi.puppet.com'
      proxy_url  = forge.key?('proxy_url') ? forge['proxy_url'] : ''
      proxy_port = forge.key?('proxy_port') ? forge['proxy_port'] : ''
      proxy_user = forge.key?('proxy_user') ? forge['proxy_user'] : ''
      proxy_pass = forge.key?('proxy_pass') ? forge['proxy_pass'] : ''
    end

  end

  base_uri forge_url

  if proxy_url != ''
    if proxy_user != ''
      http_proxy proxy_url, proxy_port, proxy_user, proxy_pass
    else
      http_proxy proxy_url, proxy_port
    end
  end

  # call forgeapi with module slug and extract version and deprecation date
  def self.get_current_module_data(mod)
    ret      = {}
    uri      = "/v3/modules/#{mod}"
    response = get(uri)
    case response.code
    when 200..399
      details    = JSON.parse(response.body)
      version    = details['current_release']['version']
      deprecated = details['current_release']['module']['deprecated_at'].nil? ? 'no' : 'yes'
    else
      version    = ''
      deprecated = 'no'
    end

    ret[:version]    = version
    ret[:deprecated] = deprecated
    ret
  end
end
