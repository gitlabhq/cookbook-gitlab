#
# Cookbook Name:: gitlab
# Recipe:: install
#

gitlab = node['gitlab']

# Merge environmental variables
gitlab = Chef::Mixin::DeepMerge.merge(gitlab,gitlab[gitlab['env']])

# Setup all package, user, etc. requirements of GitLab
include_recipe "gitlab::initial"

# Setup gitlab_shell
include_recipe "gitlab::gitlab_shell"

# Setup chosen database
include_recipe "gitlab::database_#{gitlab['database_adapter']}"

# 6. GitLab
## Clone the Source
git gitlab['path'] do
  repository gitlab['repository']
  revision gitlab['revision']
  user gitlab['user']
  group gitlab['group']
  action :sync
end

# Install required gems
include_recipe "gitlab::gems"

# Configure GitLab
include_recipe "gitlab::gitlab"

# Start GitLab if in production
if gitlab['env'] == 'production'
  ## Start Your GitLab Instance
  service "gitlab" do
    supports :start => true, :stop => true, :restart => true, :status => true
    action :enable
  end

  file File.join(gitlab['home'], ".gitlab_start") do
    owner gitlab['user']
    group gitlab['group']
    action :create_if_missing
    notifies :start, "service[gitlab]"
  end
end

# Setup and configure nginx
include_recipe "gitlab::nginx" if gitlab['env'] == 'production'
