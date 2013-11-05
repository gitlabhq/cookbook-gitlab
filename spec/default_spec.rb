require 'spec_helper'

describe "gitlab::default" do
  let(:chef_run) { ChefSpec::Runner.new.converge("gitlab::default") }


  describe "under ubuntu" do
    ["12.04", "10.04"].each do |version|
      let(:chef_run) do 
        runner = ChefSpec::Runner.new(platform: "ubuntu", version: version)
        runner.node.set['gitlab']['env'] = "production"
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
        expect(chef_run).to include_recipe("gitlab::setup")
        expect(chef_run).to include_recipe("gitlab::deploy")
      end

      describe "when in development environment" do
        let(:chef_run) do 
          runner = ChefSpec::Runner.new(platform: "ubuntu", version: version)
          runner.node.set['gitlab']['env'] = "development"
          runner.converge("gitlab::default")
        end

        it "includes recipes from external cookbooks" do
          expect(chef_run).to include_recipe("gitlab::setup")
          expect(chef_run).to include_recipe("gitlab::deploy")
        end
      end
    end
  end

  describe "under centos" do
    ["5.8", "6.4"].each do |version|
      let(:chef_run) do 
        runner = ChefSpec::Runner.new(platform: "centos", version: version)
        runner.node.set['gitlab']['env'] = "production"
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
        expect(chef_run).to include_recipe("gitlab::setup")
        expect(chef_run).to include_recipe("gitlab::deploy")
      end


      describe "when in development environment" do
        let(:chef_run) do 
          runner = ChefSpec::Runner.new(platform: "centos", version: version)
          runner.node.set['gitlab']['env'] = "development"
          runner.converge("gitlab::default")
        end

        it "includes recipes from external cookbooks" do
          expect(chef_run).to include_recipe("gitlab::setup")
          expect(chef_run).to include_recipe("gitlab::deploy")
        end
      end
    end
  end
end
