require_relative "config"
require "octokit"

module Prefaux
  # Permits the fauxpaas team to read the github repo
  class Permitter
    def initialize(repo)
      @repo = File.basename(repo).split(".").first
      @client = Octokit::Client.new(access_token: token)
    end

    def execute
      client.add_team_repo(faux_team.id, "#{org}/#{repo}", {
        permission: "pull"
      })
    end

    def faux_team
      client.organization_teams(org)
        .find{|team| team.name == Prefaux.settings.faux_team}
    end

    def token
      Prefaux.settings.api_key
    end

    def org
      Prefaux.settings.org
    end

    private
    attr_reader :client, :repo
  end
end
