#
# Cookbook Name:: gitlab
# Recipe:: default
#

gitlab = node['gitlab']

# Merge environmental variables
gitlab = Chef::Mixin::DeepMerge.merge(gitlab,gitlab[gitlab['env']])

# Setup all package, user, etc. requirements of GitLab
include_recipe "gitlab::initial"

# Fetch GitLab shell source code
include_recipe "gitlab::gitlab_shell_clone"

# Configure and install GitLab shell
include_recipe "gitlab::gitlab_shell_install"

# Setup chosen database
include_recipe "gitlab::database_#{gitlab['database_adapter']}"

# Fetch GitLab source code
include_recipe "gitlab::clone"

# Install required gems
include_recipe "gitlab::gems"

# Configure and install GitLab
include_recipe "gitlab::install"

# Start GitLab if in production
include_recipe "gitlab::start"

# Setup and configure nginx
include_recipe "gitlab::nginx" if gitlab['env'] == 'production'
