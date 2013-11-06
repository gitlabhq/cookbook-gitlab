#
# Cookbook Name:: gitlab
# Recipe:: setup
#
# This recipe is used for AWS OpsWorks setup section
# Any change must be tested against AWS OpsWorks stack

gitlab = node['gitlab']

# Merge environmental variables
gitlab = Chef::Mixin::DeepMerge.merge(gitlab,gitlab[gitlab['env']])

# Install GitLab required packages
include_recipe "gitlab::packages"

# Compile ruby
include_recipe "gitlab::ruby"

# Setup GitLab user
include_recipe "gitlab::users"

# Setup chosen database
include_recipe "gitlab::database_#{gitlab['database_adapter']}"
