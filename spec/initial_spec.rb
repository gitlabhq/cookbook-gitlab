require 'spec_helper'

describe "gitlab::initial" do
  let(:chef_run) { ChefSpec::Runner.new.converge("gitlab::initial") }


  describe "under ubuntu" do
    ["12.04", "10.04"].each do |version|
      let(:chef_run) { ChefSpec::Runner.new(platform: "ubuntu", version: version).converge("gitlab::initial") }

      before do
        # stubbing git commands because initial recipe requires gitlab::git
        stub_command("test -f /var/chef/cache/git-1.7.12.4.zip").and_return(true)
        stub_command("git --version | grep 1.7.12.4").and_return(true)
        stub_command("git --version >/dev/null").and_return(true)
      end

      it "installs all default packages" do
        packages = chef_run.node['gitlab']['packages']
        packages.each do |pkg|
          expect(chef_run).to install_package(pkg)
        end
      end
    end
  end

  describe "under centos" do
    ["5.8", "6.4"].each do |version|
      let(:chef_run) { ChefSpec::Runner.new(platform: "centos", version: version).converge("gitlab::initial") }

      before do
        # stubbing git commands because initial recipe requires gitlab::git
        stub_command("test -f /var/chef/cache/git-1.7.12.4.zip").and_return(true)
        stub_command("git --version | grep 1.7.12.4").and_return(true)
        stub_command("git --version >/dev/null").and_return(true)
      end

      it "installs all default packages" do
        packages = chef_run.node['gitlab']['packages']
        packages.each do |pkg|
          expect(chef_run).to install_package(pkg)
        end
      end
    end
  end
end
