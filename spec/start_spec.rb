require 'spec_helper'

describe "gitlab::start" do
  let(:chef_run) { ChefSpec::Runner.new.converge("gitlab::start") }


  describe "under ubuntu" do
    ["12.04", "10.04"].each do |version|
      let(:chef_run) do 
        runner = ChefSpec::Runner.new(platform: "ubuntu", version: version)
        runner.node.set['gitlab']['env'] = "production"
        runner.converge("gitlab::start")
      end

      it 'enables gitlab service' do
        expect(chef_run).to enable_service('gitlab')
      end

      it 'creates an empty file that will trigger gitlab start' do
        expect(chef_run).to create_file_if_missing('/home/git/.gitlab_start').with(
          user:   'git',
          group:  'git'
        )
      end

      describe "when empty gitlab_start file is created" do
        let(:gitlab_start) { chef_run.file("/home/git/.gitlab_start") }

        it "sends start notification to gitlab service" do
          expect(gitlab_start).to notify('service[gitlab]').to(:start).delayed
        end
      end

      describe "in development" do
        let(:chef_run) do 
          runner = ChefSpec::Runner.new(platform: "ubuntu", version: version)
          runner.node.set['gitlab']['env'] = "development"
          runner.converge("gitlab::start")
        end

        it 'doesnt enable gitlab service' do
          expect(chef_run).to_not enable_service('gitlab')
        end

        it 'doesnt create an empty file that will trigger gitlab start' do
          expect(chef_run).to_not create_file_if_missing('/home/git/.gitlab_start').with(
            user:   'git',
            group:  'git'
          )
        end
      end
    end
  end

  describe "under centos" do
    ["5.8", "6.4"].each do |version|
      let(:chef_run) do 
        runner = ChefSpec::Runner.new(platform: "centos", version: version)
        runner.node.set['gitlab']['env'] = "production"
        runner.converge("gitlab::start")
      end

      it 'enables gitlab service' do
        expect(chef_run).to enable_service('gitlab')
      end

      it 'creates an empty file that will trigger gitlab start' do
        expect(chef_run).to create_file_if_missing('/home/git/.gitlab_start').with(
          user:   'git',
          group:  'git'
        )
      end

      describe "when empty gitlab_start file is created" do
        let(:gitlab_start) { chef_run.file("/home/git/.gitlab_start") }

        it "sends start notification to gitlab service" do
          expect(gitlab_start).to notify('service[gitlab]').to(:start).delayed
        end
      end

      describe "in development" do
        let(:chef_run) do 
          runner = ChefSpec::Runner.new(platform: "centos", version: version)
          runner.node.set['gitlab']['env'] = "development"
          runner.converge("gitlab::start")
        end

        it 'doesnt enable gitlab service' do
          expect(chef_run).to_not enable_service('gitlab')
        end

        it 'doesnt create an empty file that will trigger gitlab start' do
          expect(chef_run).to_not create_file_if_missing('/home/git/.gitlab_start').with(
            user:   'git',
            group:  'git'
          )
        end
      end
    end
  end
end