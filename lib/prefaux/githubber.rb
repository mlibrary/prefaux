require "octokit"

module Prefaux
  # Adds the team to the faux-dev repo,
  # and protects the supplied branch such that only the team
  # can push to it.
  class Githubber

    def initialize(branch, team_name)
      @branch = branch
      @team_name = team_name
      @client = Octokit::Client.new(access_token: token)
    end

    def run
      team = client.organization_teams(org)
        .find{|team| team.name == team_name}
      client.add_team_repo(team.id, "#{org}/#{dev_repo}", {
        permission: "push"
      })
      client.protect_branch("#{org}/#{dev_repo}", branch, {
        enforce_admins: false,
          required_pull_request_reviews: nil,
          required_status_checks: {
            strict: false,
            contexts: []
          },
          restrictions: {
            users: [],
            teams: [team.slug]
          }
      })
    end

    def token
      Prefaux.settings.api_key
    end

    def org
      Prefaux.settings.org
    end

    def dev_repo
      Prefaux.settings.dev_repo
    end

    private
    attr_reader :branch, :team_name, :client
  end


end
