require 'spec_helper'

describe "gitlab::gitlab" do
  let(:chef_run) { ChefSpec::Runner.new.converge("gitlab::gitlab") }


  describe "under ubuntu" do
    ["12.04", "10.04"].each do |version|
      let(:chef_run) do 
        runner = ChefSpec::Runner.new(platform: "ubuntu", version: version)
        runner.node.set['gitlab']['env'] = "production"
        runner.converge("gitlab::gitlab")
      end

      it 'creates a gitlab shell config' do
        expect(chef_run).to create_template('/home/git/gitlab/config/gitlab.yml').with(
          source: 'gitlab.yml.erb',
          variables: {
            host: 'localhost',
            port: '80',
            user: 'git',
            email_from: 'gitlab@localhost',
            support_email: 'support@localhost',
            satellites_path: '/home/git/gitlab-satellites',
            repos_path: '/home/git/repositories',
            shell_path: '/home/git/gitlab-shell'
          }
        )
      end

      describe "creating gitlab.yml" do
        let(:template) { chef_run.template('/home/git/gitlab/config/gitlab.yml') }

        it 'triggers updating of git config' do
          expect(template).to notify('bash[git config]').to(:run).immediately
        end

        it 'updates git config' do
          resource = chef_run.find_resource(:bash, 'git config')
          expect(resource.code).to eq("    git config --global user.name \"GitLab\"\n    git config --global user.email \"gitlab@localhost\"\n    git config --global core.autocrlf input\n")
          expect(resource.user).to eq("git")
          expect(resource.group).to eq("git")
          expect(resource.environment).to eq('HOME' =>"/home/git")
        end
      end

      it 'creates required directories in the rails root' do
        %w{log tmp tmp/pids tmp/sockets public/uploads}.each do |path|
          expect(chef_run).to create_directory("/home/git/gitlab/#{path}").with(
            user: 'git',
            group: 'git',
            mode: 0755
          )
        end
      end

      it 'creates satellites directory' do
       expect(chef_run).to create_directory("/home/git/gitlab-satellites").with(
          user: 'git',
          group: 'git'
        )
      end

      it 'copies unicorn.rb example file' do
        expect(chef_run).to create_remote_file('/home/git/gitlab/config/unicorn.rb').with(source: "file:///home/git/gitlab/config/unicorn.rb.example")
      end

      it 'copies rack_attack.rb example file' do
        expect(chef_run).to create_remote_file('/home/git/gitlab/config/initializers/rack_attack.rb').with(mode: 0644, source: "file:///home/git/gitlab/config/initializers/rack_attack.rb.example")
      end

      describe "creating rack_attack.rb" do
        let(:copied_file) { chef_run.remote_file('/home/git/gitlab/config/initializers/rack_attack.rb') }

        it 'triggers uncommenting the line in application.rb' do
          expect(copied_file).to notify('bash[Enable rack attack in application.rb]').to(:run).immediately
        end
      end

      describe "when using mysql" do
        let(:chef_run) do 
          runner = ChefSpec::Runner.new(platform: "ubuntu", version: version)
          runner.node.set['gitlab']['env'] = "production"
          runner.node.set['gitlab']['database_adapter'] = "mysql"
          runner.node.set['gitlab']['database_password'] = "datapass"
          runner.converge("gitlab::gitlab")
        end

        it 'creates a database config' do
          expect(chef_run).to create_template('/home/git/gitlab/config/database.yml').with(
            source: 'database.yml.mysql.erb',
            user: 'git',
            group: 'git',
            variables: {
              user: 'git',
              password: 'datapass'
            }
          )
        end
      end

      describe "when using postgresql" do
        let(:chef_run) do 
          runner = ChefSpec::Runner.new(platform: "ubuntu", version: version)
          runner.node.set['gitlab']['env'] = "production"
          runner.node.set['gitlab']['database_adapter'] = "postgresql"
          runner.node.set['gitlab']['database_password'] = "datapass"
          runner.converge("gitlab::gitlab")
        end

        it 'creates a database config' do
          expect(chef_run).to create_template('/home/git/gitlab/config/database.yml').with(
            source: 'database.yml.postgresql.erb',
            user: 'git',
            group: 'git',
            variables: {
              user: 'git',
              password: 'datapass'
            }
          )
        end
      end

      describe "running database setup, migrations and seed when production" do
        it 'runs an execute to rake db:setup' do
          expect(chef_run).to run_execute('rake db:setup')
        end

        it 'runs db setup' do
          resource = chef_run.find_resource(:execute, 'rake db:setup')
          expect(resource.command).to eq("      PATH=\"/usr/local/bin:$PATH\"\n      bundle exec rake db:setup RAILS_ENV=production\n")
          expect(resource.user).to eq("git")
          expect(resource.group).to eq("git")
          expect(resource.cwd).to eq("/home/git/gitlab")
        end

        it 'creates a file with attributes' do
          expect(chef_run).to create_file('/home/git/.gitlab_setup_production').with(
            user:   'git',
            group:  'git'
          )
        end

        it 'runs an execute to rake db:migrate' do
          expect(chef_run).to run_execute('rake db:migrate')
        end

        it 'runs db migrate' do
          resource = chef_run.find_resource(:execute, 'rake db:migrate')
          expect(resource.command).to eq("      PATH=\"/usr/local/bin:$PATH\"\n      bundle exec rake db:migrate RAILS_ENV=production\n")
          expect(resource.user).to eq("git")
          expect(resource.group).to eq("git")
          expect(resource.cwd).to eq("/home/git/gitlab")
        end

        it 'creates a file with attributes' do
          expect(chef_run).to create_file('/home/git/.gitlab_migrate_production').with(
            user:   'git',
            group:  'git'
          )
        end

        it 'runs an execute to rake db:seed' do
          expect(chef_run).to run_execute('rake db:seed_fu')
        end

        it 'runs db seed' do
          resource = chef_run.find_resource(:execute, 'rake db:seed_fu')
          expect(resource.command).to eq("      PATH=\"/usr/local/bin:$PATH\"\n      bundle exec rake db:seed_fu RAILS_ENV=production\n")
          expect(resource.user).to eq("git")
          expect(resource.group).to eq("git")
          expect(resource.cwd).to eq("/home/git/gitlab")
        end

        it 'creates a file with attributes' do
          expect(chef_run).to create_file('/home/git/.gitlab_seed_production').with(
            user:   'git',
            group:  'git'
          )
        end
      end

      describe "running database setup, migrations and seed when development" do
        let(:chef_run) do 
          runner = ChefSpec::Runner.new(platform: "ubuntu", version: version)
          runner.node.set['gitlab']['env'] = "development"
          runner.converge("gitlab::gitlab")
        end

        it 'runs an execute to rake db:setup' do
          expect(chef_run).to run_execute('rake db:setup')
        end

        it 'runs db setup for all environments' do
          resources = chef_run.find_resources(:execute).select {|n| n.name == "rake db:setup"}
          dev_resource = resources.first
          test_resource = resources.last

          expect(dev_resource.command).to eq("      PATH=\"/usr/local/bin:$PATH\"\n      bundle exec rake db:setup RAILS_ENV=development\n")
          expect(dev_resource.user).to eq("vagrant")
          expect(dev_resource.group).to eq("vagrant")
          expect(dev_resource.cwd).to eq("/vagrant/gitlab")

          expect(test_resource.command).to eq("      PATH=\"/usr/local/bin:$PATH\"\n      bundle exec rake db:setup RAILS_ENV=test\n")
          expect(test_resource.user).to eq("vagrant")
          expect(test_resource.group).to eq("vagrant")
          expect(test_resource.cwd).to eq("/vagrant/gitlab")
        end

        it 'creates a file with attributes' do
          expect(chef_run).to create_file('/home/vagrant/.gitlab_setup_test').with(
            user:   'vagrant',
            group:  'vagrant'
          )
        end

        it 'runs an execute to rake db:migrate' do
          expect(chef_run).to run_execute('rake db:migrate')
        end

        it 'runs db migrate for all environments' do
          resources = chef_run.find_resources(:execute).select {|n| n.name == "rake db:migrate"}
          dev_resource = resources.first
          test_resource = resources.last

          expect(dev_resource.command).to eq("      PATH=\"/usr/local/bin:$PATH\"\n      bundle exec rake db:migrate RAILS_ENV=development\n")
          expect(dev_resource.user).to eq("vagrant")
          expect(dev_resource.group).to eq("vagrant")
          expect(dev_resource.cwd).to eq("/vagrant/gitlab")

          expect(test_resource.command).to eq("      PATH=\"/usr/local/bin:$PATH\"\n      bundle exec rake db:migrate RAILS_ENV=test\n")
          expect(test_resource.user).to eq("vagrant")
          expect(test_resource.group).to eq("vagrant")
          expect(test_resource.cwd).to eq("/vagrant/gitlab")
        end

        it 'creates a file with attributes' do
          expect(chef_run).to create_file('/home/vagrant/.gitlab_migrate_test').with(
            user:   'vagrant',
            group:  'vagrant'
          )
        end

        it 'runs an execute to rake db:seed' do
          expect(chef_run).to run_execute('rake db:seed_fu')
        end

        it 'runs db seed' do
          resources = chef_run.find_resources(:execute).select {|n| n.name == "rake db:seed_fu"}
          dev_resource = resources.first
          test_resource = resources.last

          expect(dev_resource.command).to eq("      PATH=\"/usr/local/bin:$PATH\"\n      bundle exec rake db:seed_fu RAILS_ENV=development\n")
          expect(dev_resource.user).to eq("vagrant")
          expect(dev_resource.group).to eq("vagrant")
          expect(dev_resource.cwd).to eq("/vagrant/gitlab")

          expect(test_resource.command).to eq("      PATH=\"/usr/local/bin:$PATH\"\n      bundle exec rake db:seed_fu RAILS_ENV=test\n")
          expect(test_resource.user).to eq("vagrant")
          expect(test_resource.group).to eq("vagrant")
          expect(test_resource.cwd).to eq("/vagrant/gitlab")
        end

        it 'creates a gitlab_seed file with attributes' do
          expect(chef_run).to create_file('/home/vagrant/.gitlab_seed_development').with(
            user:   'vagrant',
            group:  'vagrant'
          )
          expect(chef_run).to create_file('/home/vagrant/.gitlab_seed_test').with(
            user:   'vagrant',
            group:  'vagrant'
          )
        end
      end

      it 'copies gitlab init example file' do
        expect(chef_run).to create_remote_file('/etc/init.d/gitlab').with(source: "file:///home/git/gitlab/lib/support/init.d/gitlab")
      end

      describe "creating gitlab init" do
        let(:copied_file) { chef_run.remote_file('/etc/init.d/gitlab') }

        describe "for production" do
          it 'triggers service defaults update' do
            expect(copied_file).to notify('execute[set gitlab to start on boot]').to(:run).immediately
          end
        end

        describe "for development" do
          let(:chef_run) do 
            runner = ChefSpec::Runner.new(platform: "ubuntu", version: version)
            runner.node.set['gitlab']['env'] = "development"
            runner.converge("gitlab::gitlab")
          end

          it 'copies gitlab init example file' do
            expect(chef_run).to_not create_remote_file('/etc/init.d/gitlab').with(source: "file:///home/git/gitlab/lib/support/init.d/gitlab")
          end

          it 'includes phantomjs recipe' do
            expect(chef_run).to include_recipe("phantomjs::default")
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
        runner.converge("gitlab::gitlab")
      end

      it 'creates a gitlab shell config' do
        expect(chef_run).to create_template('/home/git/gitlab/config/gitlab.yml').with(
          source: 'gitlab.yml.erb',
          variables: {
            host: 'localhost',
            port: '80',
            user: 'git',
            email_from: 'gitlab@localhost',
            support_email: 'support@localhost',
            satellites_path: '/home/git/gitlab-satellites',
            repos_path: '/home/git/repositories',
            shell_path: '/home/git/gitlab-shell'
          }
        )
      end

      describe "creating gitlab.yml" do
        let(:template) { chef_run.template('/home/git/gitlab/config/gitlab.yml') }

        it 'triggers updating of git config' do
          expect(template).to notify('bash[git config]').to(:run).immediately
        end

        it 'updates git config' do
          resource = chef_run.find_resource(:bash, 'git config')
          expect(resource.code).to eq("    git config --global user.name \"GitLab\"\n    git config --global user.email \"gitlab@localhost\"\n    git config --global core.autocrlf input\n")
          expect(resource.user).to eq("git")
          expect(resource.group).to eq("git")
          expect(resource.environment).to eq('HOME' =>"/home/git")
        end
      end

      it 'creates required directories in the rails root' do
        %w{log tmp tmp/pids tmp/sockets public/uploads}.each do |path|
          expect(chef_run).to create_directory("/home/git/gitlab/#{path}").with(
            user: 'git',
            group: 'git',
            mode: 0755
          )
        end
      end

      it 'creates satellites directory' do
       expect(chef_run).to create_directory("/home/git/gitlab-satellites").with(
          user: 'git',
          group: 'git'
        )
      end

      it 'copies unicorn.rb example file' do
        expect(chef_run).to create_remote_file('/home/git/gitlab/config/unicorn.rb').with(source: "file:///home/git/gitlab/config/unicorn.rb.example")
      end

      it 'copies rack_attack.rb example file' do
        expect(chef_run).to create_remote_file('/home/git/gitlab/config/initializers/rack_attack.rb').with(mode: 0644, source: "file:///home/git/gitlab/config/initializers/rack_attack.rb.example")
      end

      describe "creating rack_attack.rb" do
        let(:copied_file) { chef_run.remote_file('/home/git/gitlab/config/initializers/rack_attack.rb') }

        it 'triggers uncommenting the line in application.rb' do
          expect(copied_file).to notify('bash[Enable rack attack in application.rb]').to(:run).immediately
        end
      end

      describe "when using mysql" do
        let(:chef_run) do 
          runner = ChefSpec::Runner.new(platform: "centos", version: version)
          runner.node.set['gitlab']['env'] = "production"
          runner.node.set['gitlab']['database_adapter'] = "mysql"
          runner.node.set['gitlab']['database_password'] = "datapass"
          runner.converge("gitlab::gitlab")
        end

        it 'creates a database config' do
          expect(chef_run).to create_template('/home/git/gitlab/config/database.yml').with(
            source: 'database.yml.mysql.erb',
            user: 'git',
            group: 'git',
            variables: {
              user: 'git',
              password: 'datapass'
            }
          )
        end
      end

      describe "when using postgresql" do
        let(:chef_run) do 
          runner = ChefSpec::Runner.new(platform: "centos", version: version)
          runner.node.set['gitlab']['env'] = "production"
          runner.node.set['gitlab']['database_adapter'] = "postgresql"
          runner.node.set['gitlab']['database_password'] = "datapass"
          runner.converge("gitlab::gitlab")
        end

        it 'creates a database config' do
          expect(chef_run).to create_template('/home/git/gitlab/config/database.yml').with(
            source: 'database.yml.postgresql.erb',
            user: 'git',
            group: 'git',
            variables: {
              user: 'git',
              password: 'datapass'
            }
          )
        end
      end

      describe "running database setup, migrations and seed when production" do
        it 'runs an execute to rake db:setup' do
          expect(chef_run).to run_execute('rake db:setup')
        end

        it 'runs db setup' do
          resource = chef_run.find_resource(:execute, 'rake db:setup')
          expect(resource.command).to eq("      PATH=\"/usr/local/bin:$PATH\"\n      bundle exec rake db:setup RAILS_ENV=production\n")
          expect(resource.user).to eq("git")
          expect(resource.group).to eq("git")
          expect(resource.cwd).to eq("/home/git/gitlab")
        end

        it 'creates a file with attributes' do
          expect(chef_run).to create_file('/home/git/.gitlab_setup_production').with(
            user:   'git',
            group:  'git'
          )
        end

        it 'runs an execute to rake db:migrate' do
          expect(chef_run).to run_execute('rake db:migrate')
        end

        it 'runs db migrate' do
          resource = chef_run.find_resource(:execute, 'rake db:migrate')
          expect(resource.command).to eq("      PATH=\"/usr/local/bin:$PATH\"\n      bundle exec rake db:migrate RAILS_ENV=production\n")
          expect(resource.user).to eq("git")
          expect(resource.group).to eq("git")
          expect(resource.cwd).to eq("/home/git/gitlab")
        end

        it 'creates a file with attributes' do
          expect(chef_run).to create_file('/home/git/.gitlab_migrate_production').with(
            user:   'git',
            group:  'git'
          )
        end

        it 'runs an execute to rake db:seed' do
          expect(chef_run).to run_execute('rake db:seed_fu')
        end

        it 'runs db seed' do
          resource = chef_run.find_resource(:execute, 'rake db:seed_fu')
          expect(resource.command).to eq("      PATH=\"/usr/local/bin:$PATH\"\n      bundle exec rake db:seed_fu RAILS_ENV=production\n")
          expect(resource.user).to eq("git")
          expect(resource.group).to eq("git")
          expect(resource.cwd).to eq("/home/git/gitlab")
        end

        it 'creates a file with attributes' do
          expect(chef_run).to create_file('/home/git/.gitlab_seed_production').with(
            user:   'git',
            group:  'git'
          )
        end
      end

      describe "running database setup, migrations and seed when development" do
        let(:chef_run) do 
          runner = ChefSpec::Runner.new(platform: "centos", version: version)
          runner.node.set['gitlab']['env'] = "development"
          runner.converge("gitlab::gitlab")
        end

        it 'runs an execute to rake db:setup' do
          expect(chef_run).to run_execute('rake db:setup')
        end

        it 'runs db setup for all environments' do
          resources = chef_run.find_resources(:execute).select {|n| n.name == "rake db:setup"}
          dev_resource = resources.first
          test_resource = resources.last

          expect(dev_resource.command).to eq("      PATH=\"/usr/local/bin:$PATH\"\n      bundle exec rake db:setup RAILS_ENV=development\n")
          expect(dev_resource.user).to eq("vagrant")
          expect(dev_resource.group).to eq("vagrant")
          expect(dev_resource.cwd).to eq("/vagrant/gitlab")

          expect(test_resource.command).to eq("      PATH=\"/usr/local/bin:$PATH\"\n      bundle exec rake db:setup RAILS_ENV=test\n")
          expect(test_resource.user).to eq("vagrant")
          expect(test_resource.group).to eq("vagrant")
          expect(test_resource.cwd).to eq("/vagrant/gitlab")
        end

        it 'creates a file with attributes' do
          expect(chef_run).to create_file('/home/vagrant/.gitlab_setup_test').with(
            user:   'vagrant',
            group:  'vagrant'
          )
        end

        it 'runs an execute to rake db:migrate' do
          expect(chef_run).to run_execute('rake db:migrate')
        end

        it 'runs db migrate for all environments' do
          resources = chef_run.find_resources(:execute).select {|n| n.name == "rake db:migrate"}
          dev_resource = resources.first
          test_resource = resources.last

          expect(dev_resource.command).to eq("      PATH=\"/usr/local/bin:$PATH\"\n      bundle exec rake db:migrate RAILS_ENV=development\n")
          expect(dev_resource.user).to eq("vagrant")
          expect(dev_resource.group).to eq("vagrant")
          expect(dev_resource.cwd).to eq("/vagrant/gitlab")

          expect(test_resource.command).to eq("      PATH=\"/usr/local/bin:$PATH\"\n      bundle exec rake db:migrate RAILS_ENV=test\n")
          expect(test_resource.user).to eq("vagrant")
          expect(test_resource.group).to eq("vagrant")
          expect(test_resource.cwd).to eq("/vagrant/gitlab")
        end

        it 'creates a file with attributes' do
          expect(chef_run).to create_file('/home/vagrant/.gitlab_migrate_test').with(
            user:   'vagrant',
            group:  'vagrant'
          )
        end

        it 'runs an execute to rake db:seed' do
          expect(chef_run).to run_execute('rake db:seed_fu')
        end

        it 'runs db seed' do
          resources = chef_run.find_resources(:execute).select {|n| n.name == "rake db:seed_fu"}
          dev_resource = resources.first
          test_resource = resources.last

          expect(dev_resource.command).to eq("      PATH=\"/usr/local/bin:$PATH\"\n      bundle exec rake db:seed_fu RAILS_ENV=development\n")
          expect(dev_resource.user).to eq("vagrant")
          expect(dev_resource.group).to eq("vagrant")
          expect(dev_resource.cwd).to eq("/vagrant/gitlab")

          expect(test_resource.command).to eq("      PATH=\"/usr/local/bin:$PATH\"\n      bundle exec rake db:seed_fu RAILS_ENV=test\n")
          expect(test_resource.user).to eq("vagrant")
          expect(test_resource.group).to eq("vagrant")
          expect(test_resource.cwd).to eq("/vagrant/gitlab")
        end

        it 'creates a gitlab_seed file with attributes' do
          expect(chef_run).to create_file('/home/vagrant/.gitlab_seed_development').with(
            user:   'vagrant',
            group:  'vagrant'
          )
          expect(chef_run).to create_file('/home/vagrant/.gitlab_seed_test').with(
            user:   'vagrant',
            group:  'vagrant'
          )
        end
      end

      it 'copies gitlab init example file' do
        expect(chef_run).to create_remote_file('/etc/init.d/gitlab').with(source: "file:///home/git/gitlab/lib/support/init.d/gitlab")
      end

      describe "creating gitlab init" do
        let(:copied_file) { chef_run.remote_file('/etc/init.d/gitlab') }

        describe "for production" do
          it 'triggers service defaults update' do
            expect(copied_file).to notify('execute[set gitlab to start on boot]').to(:run).immediately
          end
        end

        describe "for development" do
          let(:chef_run) do 
            runner = ChefSpec::Runner.new(platform: "centos", version: version)
            runner.node.set['gitlab']['env'] = "development"
            runner.converge("gitlab::gitlab")
          end

          it 'copies gitlab init example file' do
            expect(chef_run).to_not create_remote_file('/etc/init.d/gitlab').with(source: "file:///home/git/gitlab/lib/support/init.d/gitlab")
          end

          it 'includes phantomjs recipe' do
            expect(chef_run).to include_recipe("phantomjs::default")
          end
        end
      end
    end
  end
end
