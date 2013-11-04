#
# Cookbook Name:: gitlab
# Recipe:: start
#

gitlab = node['gitlab']

# Merge environmental variables
gitlab = Chef::Mixin::DeepMerge.merge(gitlab,gitlab[gitlab['env']])

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