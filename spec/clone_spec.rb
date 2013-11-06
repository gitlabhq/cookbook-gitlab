require 'spec_helper'

describe "gitlab::clone" do
  let(:chef_run) { ChefSpec::Runner.new.converge("gitlab::clone") }


  describe "under ubuntu" do
    ["12.04", "10.04"].each do |version|
      let(:chef_run) do 
        runner = ChefSpec::Runner.new(platform: "ubuntu", version: version)
        runner.node.set['gitlab']['env'] = "production"
        runner.converge("gitlab::clone")
      end

      it "clones the gitlab repository" do
        expect(chef_run).to sync_git('/home/git/gitlab').with(
          repository: 'https://github.com/gitlabhq/gitlabhq.git',
          revision: '6-2-stable',
          user: 'git',
          group: 'git'
        )
      end

      describe "in development" do
        let(:chef_run) do 
          runner = ChefSpec::Runner.new(platform: "ubuntu", version: version)
          runner.node.set['gitlab']['env'] = "development"
          runner.converge("gitlab::clone")
        end

        it "clones the gitlab repository" do
          expect(chef_run).to sync_git('/vagrant/gitlab').with(
            repository: 'https://github.com/gitlabhq/gitlabhq.git',
            revision: 'master',
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
        runner.converge("gitlab::clone")
      end

      it "clones the gitlab repository" do
        expect(chef_run).to sync_git('/home/git/gitlab').with(
          repository: 'https://github.com/gitlabhq/gitlabhq.git',
          revision: '6-2-stable',
          user: 'git',
          group: 'git'
        )
      end

      describe "in development" do
        let(:chef_run) do 
          runner = ChefSpec::Runner.new(platform: "centos", version: version)
          runner.node.set['gitlab']['env'] = "development"
          runner.converge("gitlab::clone")
        end

        it "clones the gitlab repository" do
          expect(chef_run).to sync_git('/vagrant/gitlab').with(
            repository: 'https://github.com/gitlabhq/gitlabhq.git',
            revision: 'master',
            user: 'vagrant',
            group: 'vagrant'
          )
        end
      end
    end
  end
end