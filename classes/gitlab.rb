# frozen_string_literal: true

class Gitlab
  attr_reader :gitlab_url, :token
  attr_writer :cache

  require 'naturally'


  def initialize(gitlab_url, token)
    @gitlab_url = gitlab_url
    @token      = token
    @cache      = {}

    build_projects_cache()
  end


  def get_repo_id_by_name(project_name)
    if @cache.key?(project_name)
      id = @cache[project_name]['id']
    else
      id = ''
    end

    id.to_s
  end


  def get_highest_tag(repository)
    tags = get_repository_tags(repository)
    tags[0]
  end


  def print_cache
    pp @cache
  end


  private


  def build_projects_cache
    cont = true
    uri  = "/api/v4/projects?page=1&per_page=100&order_by=id&sort=asc"
    while cont do
      ret = GitlabClient.get_projects(uri)
      unless ret['cache'].empty?
        local  = JSON.parse(ret['cache'])
        @cache = @cache.merge(local)
      end
      if ret['uri'].empty?
        cont = false
      else
        cont = true
        uri  = ret['uri']
      end
    end
  end


  def get_results_paginated(url, max_entries = 100)
    pagination = "pagination=keyset&per_page=#{max_entries}&order_by=id"
    url_full   = "#{url}?#{pagination}"
  end


  def get_repository_tags(repository)
    cont = true
    tags = []
    uri  = "/api/v4/projects/#{repository}/repository/tags?page=1&per_page=100&order_by=name&sort=desc"
    while cont do
      ret = GitlabClient.get_repository_tags(uri)
      unless ret['tags'].empty?
        tags = Naturally.sort(JSON.parse(ret['tags'])).reverse
      end
      if ret['uri'].empty?
        cont = false
      else
        cont = true
        uri  = ret['uri']
      end
    end

    tags
  end
end
