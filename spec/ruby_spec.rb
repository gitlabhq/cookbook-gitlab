require 'spec_helper'

describe "gitlab::ruby" do
  let(:chef_run) { ChefSpec::Runner.new.converge("gitlab::ruby") }


  describe "under ubuntu" do
    ["12.04", "10.04"].each do |version|
      let(:chef_run) { ChefSpec::Runner.new(platform: "ubuntu", version: version).converge("gitlab::ruby") }

      before do
        stub_command("git --version >/dev/null").and_return(true)
      end
      it "includes recipes from external cookbooks" do
        expect(chef_run).to include_recipe("ruby_build::default")
      end

      it "installs bundler gem" do
        expect(chef_run).to install_gem_package("bundler")
      end
    end
  end

  describe "under centos" do
    ["5.8", "6.4"].each do |version|
      let(:chef_run) { ChefSpec::Runner.new(platform: "centos", version: version).converge("gitlab::ruby") }

      before do
        stub_command("git --version >/dev/null").and_return(true)
      end

      it "includes recipes from external cookbooks" do
        expect(chef_run).to include_recipe("ruby_build::default")
      end

      it "installs bundler gem" do
        expect(chef_run).to install_gem_package("bundler")
      end
    end
  end
end
