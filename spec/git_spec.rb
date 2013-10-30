require 'spec_helper'

describe "gitlab::git" do
  let(:chef_run) { ChefSpec::Runner.new.converge("gitlab::git") }


  describe "under ubuntu" do
    ["12.04", "10.04"].each do |version|
      let(:chef_run) do 
        runner = ChefSpec::Runner.new(platform: "ubuntu", version: version)
        runner.node.set['gitlab']['env'] = "production"
        runner.converge("gitlab::git")
      end

      before do
        stub_command("test -f /var/chef/cache/git-1.7.12.4.zip").and_return(false)
        stub_command("git --version | grep 1.7.12.4").and_return(false)
      end

      it "installs all git required packages" do
        packages = %w{unzip build-essential libcurl4-gnutls-dev libexpat1-dev gettext libz-dev libssl-dev}
        packages.each do |pkg|
          expect(chef_run).to install_package(pkg)
        end
      end

      it 'gets the source code for git' do
        expect(chef_run).to create_remote_file('/var/chef/cache/git-1.7.12.4.zip').with(mode: 0644, source: "https://github.com/git/git/archive/v1.7.12.4.zip")
      end

      it 'executes compiling git from source' do
        resource = chef_run.find_resource(:execute, 'Extracting and Building Git 1.7.12.4 from Source')
        expect(resource.command).to eq("    unzip -q git-1.7.12.4.zip\n    cd git-1.7.12.4 && make prefix=/usr/local install\n")
        expect(resource.cwd).to eq("/var/chef/cache")
      end
    end
  end

    describe "under centos" do
    ["5.8", "6.4"].each do |version|
      let(:chef_run) do 
        runner = ChefSpec::Runner.new(platform: "centos", version: version)
        runner.node.set['gitlab']['env'] = "production"
        runner.converge("gitlab::git")
      end

      before do
        stub_command("test -f /var/chef/cache/git-1.7.12.4.zip").and_return(false)
        stub_command("git --version | grep 1.7.12.4").and_return(false)
      end

      it "installs all git required packages" do
        packages = %w{expat-devel gettext-devel libcurl-devel openssl-devel perl-ExtUtils-MakeMaker zlib-devel}
        packages.each do |pkg|
          expect(chef_run).to install_package(pkg)
        end
      end

      it 'gets the source code for git' do
        expect(chef_run).to create_remote_file('/var/chef/cache/git-1.7.12.4.zip').with(mode: 0644, source: "https://github.com/git/git/archive/v1.7.12.4.zip")
      end

      it 'executes compiling git from source' do
        resource = chef_run.find_resource(:execute, 'Extracting and Building Git 1.7.12.4 from Source')
        expect(resource.command).to eq("    unzip -q git-1.7.12.4.zip\n    cd git-1.7.12.4 && make prefix=/usr/local install\n")
        expect(resource.cwd).to eq("/var/chef/cache")
      end
    end
  end
end