require 'spec_helper'

describe "gitlab::deploy" do
  let(:chef_run) { ChefSpec::Runner.new.converge("gitlab::deploy") }


  describe "under ubuntu" do
    ["12.04", "10.04"].each do |version|
      let(:chef_run) do 
        runner = ChefSpec::Runner.new(platform: "ubuntu", version: version)
        runner.node.set['gitlab']['env'] = "production"
        runner.converge("gitlab::deploy")
      end

      it "includes recipes from external cookbooks" do
        expect(chef_run).to include_recipe("gitlab::gitlab_shell_clone")
        expect(chef_run).to include_recipe("gitlab::gitlab_shell_install")
        expect(chef_run).to include_recipe("gitlab::clone")
        expect(chef_run).to include_recipe("gitlab::gems")
        expect(chef_run).to include_recipe("gitlab::install")
        expect(chef_run).to include_recipe("gitlab::nginx")
      end

      describe "when in development environment" do
        let(:chef_run) do 
          runner = ChefSpec::Runner.new(platform: "ubuntu", version: version)
          runner.node.set['gitlab']['env'] = "development"
          runner.converge("gitlab::deploy")
        end

        it "includes recipes from external cookbooks" do
          expect(chef_run).to include_recipe("gitlab::gitlab_shell_clone")
          expect(chef_run).to include_recipe("gitlab::gitlab_shell_install")
          expect(chef_run).to include_recipe("gitlab::clone")
          expect(chef_run).to include_recipe("gitlab::gems")
          expect(chef_run).to include_recipe("gitlab::install")
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
        runner.converge("gitlab::deploy")
      end

      it "includes recipes from external cookbooks" do
        expect(chef_run).to include_recipe("gitlab::gitlab_shell_clone")
        expect(chef_run).to include_recipe("gitlab::gitlab_shell_install")
        expect(chef_run).to include_recipe("gitlab::clone")
        expect(chef_run).to include_recipe("gitlab::gems")
        expect(chef_run).to include_recipe("gitlab::install")
        expect(chef_run).to include_recipe("gitlab::nginx")
      end

      describe "when in development environment" do
        let(:chef_run) do 
          runner = ChefSpec::Runner.new(platform: "centos", version: version)
          runner.node.set['gitlab']['env'] = "development"
          runner.converge("gitlab::deploy")
        end

        it "includes recipes from external cookbooks" do
          expect(chef_run).to include_recipe("gitlab::gitlab_shell_clone")
          expect(chef_run).to include_recipe("gitlab::gitlab_shell_install")
          expect(chef_run).to include_recipe("gitlab::clone")
          expect(chef_run).to include_recipe("gitlab::gems")
          expect(chef_run).to include_recipe("gitlab::install")
          expect(chef_run).to_not include_recipe("gitlab::nginx")
        end
      end
    end
  end
end
