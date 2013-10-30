## NOTE!
# Currently database recipes are untested
# This should be improved when the circumstances allow
# Reasons are explained here: https://github.com/sethvargo/chefspec/blob/v3.0.1/README.md#testing-lwrps
#

require 'spec_helper'

describe "gitlab::database_mysql" do
  let(:chef_run) { ChefSpec::Runner.new.converge("gitlab::database_mysql") }


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
        runner.converge("gitlab::database_mysql")
      end

      before do
        stub_command("\"/usr/bin/mysql\" -u root -e 'show databases;'").and_return(true)
      end

      it "includes recipes from external cookbooks" do
        expect(chef_run).to include_recipe("mysql::server")
        expect(chef_run).to include_recipe("gitlab::database_mysql")
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
        runner.converge("gitlab::database_mysql")
      end

      before do
        stub_command("\"/usr/bin/mysql\" -u root -e 'show databases;'").and_return(true)
      end

      it "includes recipes from external cookbooks" do
        expect(chef_run).to include_recipe("mysql::server")
        expect(chef_run).to include_recipe("gitlab::database_mysql")
      end
    end
  end
end
