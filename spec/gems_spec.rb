require 'spec_helper'

describe "gitlab::gems" do
  let(:chef_run) { ChefSpec::Runner.new.converge("gitlab::gems") }


  describe "under ubuntu" do
    ["12.04", "10.04"].each do |version|
      let(:chef_run) do 
        runner = ChefSpec::Runner.new(platform: "ubuntu", version: version)
        runner.node.set['gitlab']['env'] = "production"
        runner.converge("gitlab::gems")
      end

      it 'installs charlock holmes with a specific version' do
        expect(chef_run).to install_gem_package('charlock_holmes').with(version: '0.6.9.4', options: "--no-ri --no-rdoc")
      end

      it 'creates a gemrc from template' do
        expect(chef_run).to create_template('/home/git/.gemrc').with(
          source: "gemrc.erb",
          user: "git",
          group: "git",
        )
      end

      it 'does not run a execute to bundle install on its own' do
        expect(chef_run).to_not run_execute('bundle install')
      end

      describe "creating gemrc" do
        let(:template) { chef_run.template('/home/git/.gemrc') }

        it 'triggers install' do
          expect(template).to notify('execute[bundle install]').to(:run).immediately
        end

        it 'executes bundle without development and test' do
          resource = chef_run.find_resource(:execute, 'bundle install')
          expect(resource.command).to eq("    PATH=\"/usr/local/bin:$PATH\"\n    bundle install --path=.bundle --deployment --without postgres aws development test\n")
          expect(resource.user).to eq("git")
          expect(resource.group).to eq("git")
          expect(resource.cwd).to eq("/home/git/gitlab")
        end

        describe "for development" do
          let(:chef_run) do 
            runner = ChefSpec::Runner.new(platform: "ubuntu", version: version)
            runner.node.set['gitlab']['env'] = "development"
            runner.converge("gitlab::gems")
          end

          it 'executes bundle without production' do
            resource = chef_run.find_resource(:execute, 'bundle install')
            expect(resource.command).to eq("    PATH=\"/usr/local/bin:$PATH\"\n    bundle install --path=.bundle --deployment --without postgres aws production\n")
            expect(resource.user).to eq("vagrant")
            expect(resource.group).to eq("vagrant")
            expect(resource.cwd).to eq("/vagrant/gitlab")
          end
        end

        describe "when using mysql" do
          let(:chef_run) do 
            runner = ChefSpec::Runner.new(platform: "ubuntu", version: version)
            runner.node.set['gitlab']['env'] = "production"
            runner.node.set['gitlab']['database_adapter'] = "mysql"
            runner.node.set['gitlab']['database_password'] = "datapass"
            runner.node.set['mysql']['server_root_password'] = "rootpass"
            runner.node.set['mysql']['server_repl_password'] = "replpass"
            runner.node.set['mysql']['server_debian_password'] = "debpass"
            runner.converge("gitlab::gems")
          end

          it 'executes bundle without postgres' do
            resource = chef_run.find_resource(:execute, 'bundle install')
            expect(resource.command).to eq("    PATH=\"/usr/local/bin:$PATH\"\n    bundle install --path=.bundle --deployment --without postgres aws development test\n")
            expect(resource.user).to eq("git")
            expect(resource.group).to eq("git")
            expect(resource.cwd).to eq("/home/git/gitlab")
          end
        end

        describe "when using postgres" do
          let(:chef_run) do 
            runner = ChefSpec::Runner.new(platform: "ubuntu", version: version)
            runner.node.set['gitlab']['env'] = "production"
            runner.node.set['gitlab']['database_adapter'] = "postgresql"
            runner.node.set['gitlab']['database_password'] = "datapass"
            runner.node.set['postgresql']['password']['postgres'] = "psqlpass"
            runner.converge("gitlab::gems")
          end

          it 'executes bundle without mysql' do
            resource = chef_run.find_resource(:execute, 'bundle install')
            expect(resource.command).to eq("    PATH=\"/usr/local/bin:$PATH\"\n    bundle install --path=.bundle --deployment --without mysql aws development test\n")
            expect(resource.user).to eq("git")
            expect(resource.group).to eq("git")
            expect(resource.cwd).to eq("/home/git/gitlab")
          end
        end
      end
    end
  end

    describe "under centos" do
    ["5.8", "6.4"].each do |version|
      let(:chef_run) do 
        runner = ChefSpec::Runner.new(platform: "centos", version: version)
        runner.node.set['gitlab']['env'] = "production"
        runner.converge("gitlab::gems")
      end

      it 'installs charlock holmes with a specific version' do
        expect(chef_run).to install_gem_package('charlock_holmes').with(version: '0.6.9.4', options: "--no-ri --no-rdoc")
      end

      it 'creates a gemrc from template' do
        expect(chef_run).to create_template('/home/git/.gemrc').with(
          source: "gemrc.erb",
          user: "git",
          group: "git",
        )
      end

      it 'does not run a execute to bundle install on its own' do
        expect(chef_run).to_not run_execute('bundle install')
      end

      describe "creating gemrc" do
        let(:template) { chef_run.template('/home/git/.gemrc') }

        it 'triggers install' do
          expect(template).to notify('execute[bundle install]').to(:run).immediately
        end

        it 'executes bundle without development and test' do
          resource = chef_run.find_resource(:execute, 'bundle install')
          expect(resource.command).to eq("    PATH=\"/usr/local/bin:$PATH\"\n    bundle install --path=.bundle --deployment --without postgres aws development test\n")
          expect(resource.user).to eq("git")
          expect(resource.group).to eq("git")
          expect(resource.cwd).to eq("/home/git/gitlab")
        end

        describe "for development" do
          let(:chef_run) do 
            runner = ChefSpec::Runner.new(platform: "centos", version: version)
            runner.node.set['gitlab']['env'] = "development"
            runner.converge("gitlab::gems")
          end

          it 'executes bundle without production' do
            resource = chef_run.find_resource(:execute, 'bundle install')
            expect(resource.command).to eq("    PATH=\"/usr/local/bin:$PATH\"\n    bundle install --path=.bundle --deployment --without postgres aws production\n")
            expect(resource.user).to eq("vagrant")
            expect(resource.group).to eq("vagrant")
            expect(resource.cwd).to eq("/vagrant/gitlab")
          end
        end

        describe "when using mysql" do
          let(:chef_run) do 
            runner = ChefSpec::Runner.new(platform: "centos", version: version)
            runner.node.set['gitlab']['env'] = "production"
            runner.node.set['gitlab']['database_adapter'] = "mysql"
            runner.node.set['gitlab']['database_password'] = "datapass"
            runner.node.set['mysql']['server_root_password'] = "rootpass"
            runner.node.set['mysql']['server_repl_password'] = "replpass"
            runner.node.set['mysql']['server_debian_password'] = "debpass"
            runner.converge("gitlab::gems")
          end

          it 'executes bundle without postgres' do
            resource = chef_run.find_resource(:execute, 'bundle install')
            expect(resource.command).to eq("    PATH=\"/usr/local/bin:$PATH\"\n    bundle install --path=.bundle --deployment --without postgres aws development test\n")
            expect(resource.user).to eq("git")
            expect(resource.group).to eq("git")
            expect(resource.cwd).to eq("/home/git/gitlab")
          end
        end

        describe "when using postgres" do
          let(:chef_run) do 
            runner = ChefSpec::Runner.new(platform: "centos", version: version)
            runner.node.set['gitlab']['env'] = "production"
            runner.node.set['gitlab']['database_adapter'] = "postgresql"
            runner.node.set['gitlab']['database_password'] = "datapass"
            runner.node.set['postgresql']['password']['postgres'] = "psqlpass"
            runner.converge("gitlab::gems")
          end

          it 'executes bundle without mysql' do
            resource = chef_run.find_resource(:execute, 'bundle install')
            expect(resource.command).to eq("    PATH=\"/usr/local/bin:$PATH\"\n    bundle install --path=.bundle --deployment --without mysql aws development test\n")
            expect(resource.user).to eq("git")
            expect(resource.group).to eq("git")
            expect(resource.cwd).to eq("/home/git/gitlab")
          end
        end
      end
    end
  end
end
