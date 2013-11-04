#
# Cookbook Name:: gitlab
# Recipe:: opsworks_setup
#
# Used for AWS OpsWorks configure section

# Fetch GitLab shell source code
include_recipe "gitlab::gitlab_shell_source"

# Configure GitLab shell
include_recipe "gitlab::gitlab_shell"

# Fetch GitLab source code
include_recipe "gitlab::gitlab_source"

# Install required gems
include_recipe "gitlab::gems"

# Configure GitLab
include_recipe "gitlab::gitlab"

# Start GitLab if in production
include_recipe "gitlab::start"

# Setup and configure nginx
include_recipe "gitlab::nginx" if gitlab['env'] == 'production'