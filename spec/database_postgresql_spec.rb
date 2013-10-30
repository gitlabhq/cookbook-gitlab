## NOTE!
# Currently database recipes are untested
# This should be improved when the circumstances allow
# Reasons are explained here: https://github.com/sethvargo/chefspec/blob/v3.0.1/README.md#testing-lwrps
#

require 'spec_helper'

describe "gitlab::database_postgresql" do
  let(:chef_run) { ChefSpec::Runner.new.converge("gitlab::database_postgresql") }


  describe "under ubuntu" do
    ["12.04", "10.04"].each do |version|
      let(:chef_run) do 
        runner = ChefSpec::Runner.new(platform: "ubuntu", version: version)
        runner.node.set['gitlab']['env'] = "production"
        runner.node.set['gitlab']['database_adapter'] = "postgresql"
        runner.node.set['gitlab']['database_password'] = "datapass"
        runner.node.set['postgresql']['password']['postgres'] = "psqlpass"
        runner.converge("gitlab::database_postgresql")
      end

      it "includes recipes from external cookbooks" do
        expect(chef_run).to include_recipe("postgresql::server")
        expect(chef_run).to include_recipe("database::postgresql")
      end
    end
  end

    describe "under centos" do
    ["5.8", "6.4"].each do |version|
      let(:chef_run) do 
        runner = ChefSpec::Runner.new(platform: "centos", version: version)
        runner.node.set['gitlab']['env'] = "production"
        runner.node.set['gitlab']['database_adapter'] = "postgresql"
        runner.node.set['gitlab']['database_password'] = "datapass"
        runner.node.set['postgresql']['password']['postgres'] = "psqlpass"
        runner.converge("gitlab::database_postgresql")
      end

      it "includes recipes from external cookbooks" do
        expect(chef_run).to include_recipe("postgresql::server")
        expect(chef_run).to include_recipe("database::postgresql")
      end
    end
  end
end
