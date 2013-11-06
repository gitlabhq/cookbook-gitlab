require 'spec_helper'

describe "gitlab::setup" do
  let(:chef_run) { ChefSpec::Runner.new.converge("gitlab::setup") }


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
        runner.converge("gitlab::setup")
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
        expect(chef_run).to include_recipe("gitlab::database_mysql")
      end

      describe "with postgresql database" do
        let(:chef_run) do 
          runner = ChefSpec::Runner.new(platform: "ubuntu", version: version)
          runner.node.set['gitlab']['env'] = "production"
          runner.node.set['gitlab']['database_adapter'] = "postgresql"
          runner.node.set['gitlab']['database_password'] = "datapass"
          runner.node.set['postgresql']['password']['postgres'] = "psqlpass"
          runner.converge("gitlab::setup")
        end

        it "includes recipes from external cookbooks" do
          expect(chef_run).to include_recipe("gitlab::packages")
          expect(chef_run).to include_recipe("gitlab::ruby")
          expect(chef_run).to include_recipe("gitlab::users")
          expect(chef_run).to include_recipe("gitlab::database_postgresql")
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
          runner.converge("gitlab::setup")
        end

        it "includes recipes from external cookbooks" do
          expect(chef_run).to include_recipe("gitlab::packages")
          expect(chef_run).to include_recipe("gitlab::ruby")
          expect(chef_run).to include_recipe("gitlab::users")
          expect(chef_run).to include_recipe("gitlab::database_mysql")
          expect(chef_run).to_not include_recipe("gitlab::nginx")
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
        runner.converge("gitlab::setup")
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
        expect(chef_run).to include_recipe("gitlab::database_mysql")
      end

      describe "with postgresql database" do
        let(:chef_run) do 
          runner = ChefSpec::Runner.new(platform: "centos", version: version)
          runner.node.set['gitlab']['env'] = "production"
          runner.node.set['gitlab']['database_adapter'] = "postgresql"
          runner.node.set['gitlab']['database_password'] = "datapass"
          runner.node.set['postgresql']['password']['postgres'] = "psqlpass"
          runner.converge("gitlab::setup")
        end

        it "includes recipes from external cookbooks" do
          expect(chef_run).to include_recipe("gitlab::packages")
          expect(chef_run).to include_recipe("gitlab::ruby")
          expect(chef_run).to include_recipe("gitlab::users")
          expect(chef_run).to include_recipe("gitlab::database_postgresql")
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
          runner.converge("gitlab::setup")
        end

        it "includes recipes from external cookbooks" do
          expect(chef_run).to include_recipe("gitlab::packages")
          expect(chef_run).to include_recipe("gitlab::ruby")
          expect(chef_run).to include_recipe("gitlab::users")
          expect(chef_run).to include_recipe("gitlab::database_mysql")
        end
      end
    end
  end
end
