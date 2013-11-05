require 'spec_helper'

describe "gitlab::gitlab_shell_clone" do
  let(:chef_run) { ChefSpec::Runner.new.converge("gitlab::gitlab_shell_clone") }


  describe "under ubuntu" do
    ["12.04", "10.04"].each do |version|
      let(:chef_run) do 
        runner = ChefSpec::Runner.new(platform: "ubuntu", version: version)
        runner.node.set['gitlab']['env'] = "production"
        runner.converge("gitlab::gitlab_shell_clone")
      end

      it "clones the gitlab-shell repository" do
        expect(chef_run).to sync_git('/home/git/gitlab-shell').with(
          repository: 'https://github.com/gitlabhq/gitlab-shell.git',
          revision: "v1.7.4",
          user: 'git',
          group: 'git'
        )
      end

      describe "in development" do
        let(:chef_run) do 
          runner = ChefSpec::Runner.new(platform: "ubuntu", version: version)
          runner.node.set['gitlab']['env'] = "development"
          runner.converge("gitlab::gitlab_shell_clone")
        end

        it "clones the gitlab-shell repository" do
          expect(chef_run).to sync_git('/vagrant/gitlab-shell').with(
            repository: 'https://github.com/gitlabhq/gitlab-shell.git',
            revision: "v1.7.4",
            user: 'vagrant',
            group: 'vagrant'
          )
        end
      end
    end
  end

  describe "under centos" do
    ["5.8", "6.4"].each do |version|
      let(:chef_run) do 
        runner = ChefSpec::Runner.new(platform: "centos", version: version)
        runner.node.set['gitlab']['env'] = "production"
        runner.converge("gitlab::gitlab_shell_clone")
      end

      it "clones the gitlab-shell repository" do
        expect(chef_run).to sync_git('/home/git/gitlab-shell').with(
          repository: 'https://github.com/gitlabhq/gitlab-shell.git',
          revision: "v1.7.4",
          user: 'git',
          group: 'git'
        )
      end

      describe "in development" do
        let(:chef_run) do 
          runner = ChefSpec::Runner.new(platform: "centos", version: version)
          runner.node.set['gitlab']['env'] = "development"
          runner.converge("gitlab::gitlab_shell_clone")
        end

        it "clones the gitlab-shell repository" do
          expect(chef_run).to sync_git('/vagrant/gitlab-shell').with(
            repository: 'https://github.com/gitlabhq/gitlab-shell.git',
            revision: "v1.7.4",
            user: 'vagrant',
            group: 'vagrant'
          )
        end
      end
    end
  end
end