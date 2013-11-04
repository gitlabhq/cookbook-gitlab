#
# Cookbook Name:: gitlab
# Recipe:: gitlab_source
#

gitlab = node['gitlab']

# Merge environmental variables
gitlab = Chef::Mixin::DeepMerge.merge(gitlab,gitlab[gitlab['env']])

# 6. GitLab
## Clone the Source
git gitlab['path'] do
  repository gitlab['repository']
  revision gitlab['revision']
  user gitlab['user']
  group gitlab['group']
  action :sync
end
