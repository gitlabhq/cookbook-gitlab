require 'spec_helper'

describe "gitlab::default" do
  let(:chef_run) { ChefSpec::Runner.new.converge("gitlab::default") }


  describe "under ubuntu" do
    ["12.04", "10.04"].each do |version|
      let(:chef_run) do 
        runner = ChefSpec::Runner.new(platform: "ubuntu", version: version)
        runner.node.set['gitlab']['env'] = "production"
        runner.node.set['gitlab']['database_adapter'] = "mysql"
        runner.node.set['gitlab']['database_password'] = "datapass"
        runner.node.set['mysql']['server_root_password'] = "rootpass"
        runner.node.set['mysql']['server_repl_password'] = "replpass"
        runner.node.set['mysql']['server_debian_password'] = "debpass"
        runner.converge("gitlab::default")
      end

      before do
        # stubbing commands because real commands are disabled
        stub_command("test -f /var/chef/cache/git-1.7.12.4.zip").and_return(true)
        stub_command("git --version | grep 1.7.12.4").and_return(true)
        stub_command("git --version >/dev/null").and_return(true)
        stub_command("\"/usr/bin/mysql\" -u root -e 'show databases;'").and_return(true)
      end

      it "includes recipes from external cookbooks" do
        expect(chef_run).to include_recipe("gitlab::packages")
        expect(chef_run).to include_recipe("gitlab::ruby")
        expect(chef_run).to include_recipe("gitlab::users")
        expect(chef_run).to include_recipe("gitlab::gitlab_shell_clone")
        expect(chef_run).to include_recipe("gitlab::gitlab_shell_install")
        expect(chef_run).to include_recipe("gitlab::database_mysql")
        expect(chef_run).to include_recipe("gitlab::clone")
        expect(chef_run).to include_recipe("gitlab::gems")
        expect(chef_run).to include_recipe("gitlab::install")
        expect(chef_run).to include_recipe("gitlab::nginx")
      end

      it "clones the gitlab-shell repository" do
        expect(chef_run).to sync_git('/home/git/gitlab-shell').with(
          repository: 'https://github.com/gitlabhq/gitlab-shell.git', 
          revision: "v1.7.4",
          user: 'git',
          group: 'git'
        )
      end

      it "clones the gitlab repository" do
        expect(chef_run).to sync_git('/home/git/gitlab').with(
          repository: 'https://github.com/gitlabhq/gitlabhq.git',
          revision: '6-2-stable',
          user: 'git',
          group: 'git'
        )
      end

      it 'enables gitlab service' do
        expect(chef_run).to enable_service('gitlab')
      end

      it 'creates an empty file that will trigger gitlab start' do
        expect(chef_run).to create_file_if_missing('/home/git/.gitlab_start').with(
          user:   'git',
          group:  'git'
        )
      end

      describe "when empty gitlab_start file is created" do
        let(:gitlab_start) { chef_run.file("/home/git/.gitlab_start") }

        it "sends start notification to gitlab service" do
          expect(gitlab_start).to notify('service[gitlab]').to(:start).delayed
        end
      end

      describe "with postgresql database" do
        let(:chef_run) do 
          runner = ChefSpec::Runner.new(platform: "ubuntu", version: version)
          runner.node.set['gitlab']['env'] = "production"
          runner.node.set['gitlab']['database_adapter'] = "postgresql"
          runner.node.set['gitlab']['database_password'] = "datapass"
          runner.node.set['postgresql']['password']['postgres'] = "psqlpass"
          runner.converge("gitlab::default")
        end

        it "includes recipes from external cookbooks" do
          expect(chef_run).to include_recipe("gitlab::packages")
          expect(chef_run).to include_recipe("gitlab::ruby")
          expect(chef_run).to include_recipe("gitlab::users")
          expect(chef_run).to include_recipe("gitlab::gitlab_shell_clone")
          expect(chef_run).to include_recipe("gitlab::gitlab_shell_install")
          expect(chef_run).to include_recipe("gitlab::database_postgresql")
          expect(chef_run).to include_recipe("gitlab::clone")
          expect(chef_run).to include_recipe("gitlab::gems")
          expect(chef_run).to include_recipe("gitlab::install")
          expect(chef_run).to include_recipe("gitlab::nginx")
        end
      end

      describe "when in development environment" do
        let(:chef_run) do 
          runner = ChefSpec::Runner.new(platform: "ubuntu", version: version)
          runner.node.set['gitlab']['env'] = "development"
          runner.node.set['gitlab']['database_adapter'] = "mysql"
          runner.node.set['gitlab']['database_password'] = "datapass"
          runner.node.set['mysql']['server_root_password'] = "rootpass"
          runner.node.set['mysql']['server_repl_password'] = "replpass"
          runner.node.set['mysql']['server_debian_password'] = "debpass"
          runner.converge("gitlab::default")
        end

        it "includes recipes from external cookbooks" do
          expect(chef_run).to include_recipe("gitlab::packages")
          expect(chef_run).to include_recipe("gitlab::ruby")
          expect(chef_run).to include_recipe("gitlab::users")
          expect(chef_run).to include_recipe("gitlab::gitlab_shell_clone")
          expect(chef_run).to include_recipe("gitlab::gitlab_shell_install")
          expect(chef_run).to include_recipe("gitlab::database_mysql")
          expect(chef_run).to include_recipe("gitlab::clone")
          expect(chef_run).to include_recipe("gitlab::gems")
          expect(chef_run).to include_recipe("gitlab::install")
          expect(chef_run).to_not include_recipe("gitlab::nginx")
        end

        it "clones the gitlab-shell repository" do
          expect(chef_run).to sync_git('/vagrant/gitlab-shell').with(
            repository: 'https://github.com/gitlabhq/gitlab-shell.git', 
            revision: "v1.7.4",
            user: 'vagrant',
            group: 'vagrant'
          )
        end

        it "clones the gitlab repository" do
          expect(chef_run).to sync_git('/vagrant/gitlab').with(
            repository: 'https://github.com/gitlabhq/gitlabhq.git',
            revision: 'master',
            user: 'vagrant',
            group: 'vagrant'
          )
        end

        it 'does not enable gitlab service' do
          expect(chef_run).to_not enable_service('gitlab')
        end

        it 'creates an empty file that will trigger gitlab start' do
          expect(chef_run).to_not create_file_if_missing('/home/vagrant/.gitlab_start')
        end
      end
    end
  end

  describe "under centos" do
    ["5.8", "6.4"].each do |version|
      let(:chef_run) do 
        runner = ChefSpec::Runner.new(platform: "centos", version: version)
        runner.node.set['gitlab']['env'] = "production"
        runner.node.set['gitlab']['database_adapter'] = "mysql"
        runner.node.set['gitlab']['database_password'] = "datapass"
        runner.node.set['mysql']['server_root_password'] = "rootpass"
        runner.node.set['mysql']['server_repl_password'] = "replpass"
        runner.node.set['mysql']['server_debian_password'] = "debpass"
        runner.converge("gitlab::default")
      end

      before do
        # stubbing commands because real commands are disabled
        stub_command("test -f /var/chef/cache/git-1.7.12.4.zip").and_return(true)
        stub_command("git --version | grep 1.7.12.4").and_return(true)
        stub_command("git --version >/dev/null").and_return(true)
        stub_command("\"/usr/bin/mysql\" -u root -e 'show databases;'").and_return(true)
      end

      it "includes recipes from external cookbooks" do
        expect(chef_run).to include_recipe("gitlab::packages")
        expect(chef_run).to include_recipe("gitlab::ruby")
        expect(chef_run).to include_recipe("gitlab::users")
        expect(chef_run).to include_recipe("gitlab::gitlab_shell_clone")
        expect(chef_run).to include_recipe("gitlab::gitlab_shell_install")
        expect(chef_run).to include_recipe("gitlab::database_mysql")
        expect(chef_run).to include_recipe("gitlab::clone")
        expect(chef_run).to include_recipe("gitlab::gems")
        expect(chef_run).to include_recipe("gitlab::install")
        expect(chef_run).to include_recipe("gitlab::nginx")
      end

      it "clones the gitlab-shell repository" do
        expect(chef_run).to sync_git('/home/git/gitlab-shell').with(
          repository: 'https://github.com/gitlabhq/gitlab-shell.git', 
          revision: "v1.7.4",
          user: 'git',
          group: 'git'
        )
      end

      it "clones the gitlab repository" do
        expect(chef_run).to sync_git('/home/git/gitlab').with(
          repository: 'https://github.com/gitlabhq/gitlabhq.git',
          revision: '6-2-stable',
          user: 'git',
          group: 'git'
        )
      end

      it 'enables gitlab service' do
        expect(chef_run).to enable_service('gitlab')
      end

      it 'creates an empty file that will trigger gitlab start' do
        expect(chef_run).to create_file_if_missing('/home/git/.gitlab_start').with(
          user:   'git',
          group:  'git'
        )
      end

      describe "when empty gitlab_start file is created" do
        let(:gitlab_start) { chef_run.file("/home/git/.gitlab_start") }

        it "sends start notification to gitlab service" do
          expect(gitlab_start).to notify('service[gitlab]').to(:start).delayed
        end
      end

      describe "with postgresql database" do
        let(:chef_run) do 
          runner = ChefSpec::Runner.new(platform: "centos", version: version)
          runner.node.set['gitlab']['env'] = "production"
          runner.node.set['gitlab']['database_adapter'] = "postgresql"
          runner.node.set['gitlab']['database_password'] = "datapass"
          runner.node.set['postgresql']['password']['postgres'] = "psqlpass"
          runner.converge("gitlab::default")
        end

        it "includes recipes from external cookbooks" do
          expect(chef_run).to include_recipe("gitlab::packages")
          expect(chef_run).to include_recipe("gitlab::ruby")
          expect(chef_run).to include_recipe("gitlab::users")
          expect(chef_run).to include_recipe("gitlab::gitlab_shell_clone")
          expect(chef_run).to include_recipe("gitlab::gitlab_shell_install")
          expect(chef_run).to include_recipe("gitlab::database_postgresql")
          expect(chef_run).to include_recipe("gitlab::clone")
          expect(chef_run).to include_recipe("gitlab::gems")
          expect(chef_run).to include_recipe("gitlab::install")
          expect(chef_run).to include_recipe("gitlab::nginx")
        end
      end

      describe "when in development environment" do
        let(:chef_run) do 
          runner = ChefSpec::Runner.new(platform: "centos", version: version)
          runner.node.set['gitlab']['env'] = "development"
          runner.node.set['gitlab']['database_adapter'] = "mysql"
          runner.node.set['gitlab']['database_password'] = "datapass"
          runner.node.set['mysql']['server_root_password'] = "rootpass"
          runner.node.set['mysql']['server_repl_password'] = "replpass"
          runner.node.set['mysql']['server_debian_password'] = "debpass"
          runner.converge("gitlab::default")
        end

        it "includes recipes from external cookbooks" do
          expect(chef_run).to include_recipe("gitlab::packages")
          expect(chef_run).to include_recipe("gitlab::ruby")
          expect(chef_run).to include_recipe("gitlab::users")
          expect(chef_run).to include_recipe("gitlab::gitlab_shell_clone")
          expect(chef_run).to include_recipe("gitlab::gitlab_shell_install")
          expect(chef_run).to include_recipe("gitlab::database_mysql")
          expect(chef_run).to include_recipe("gitlab::clone")
          expect(chef_run).to include_recipe("gitlab::gems")
          expect(chef_run).to include_recipe("gitlab::install")
          expect(chef_run).to_not include_recipe("gitlab::nginx")
        end

        it "clones the gitlab-shell repository" do
          expect(chef_run).to sync_git('/vagrant/gitlab-shell').with(
            repository: 'https://github.com/gitlabhq/gitlab-shell.git', 
            revision: "v1.7.4",
            user: 'vagrant',
            group: 'vagrant'
          )
        end

        it "clones the gitlab repository" do
          expect(chef_run).to sync_git('/vagrant/gitlab').with(
            repository: 'https://github.com/gitlabhq/gitlabhq.git',
            revision: 'master',
            user: 'vagrant',
            group: 'vagrant'
          )
        end

        it 'does not enable gitlab service' do
          expect(chef_run).to_not enable_service('gitlab')
        end

        it 'creates an empty file that will trigger gitlab start' do
          expect(chef_run).to_not create_file_if_missing('/home/vagrant/.gitlab_start')
        end
      end
    end
  end
end
