class ForgeClient
  include HTTParty

  base_uri 'https://forgeapi.puppet.com'

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
