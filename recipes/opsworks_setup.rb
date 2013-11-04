#
# Cookbook Name:: gitlab
# Recipe:: opsworks_setup
#
# Used for AWS OpsWorks setup section

gitlab = node['gitlab']

# Merge environmental variables
gitlab = Chef::Mixin::DeepMerge.merge(gitlab,gitlab[gitlab['env']])

# Setup all package, user, etc. requirements of GitLab
include_recipe "gitlab::initial"

# Setup chosen database
include_recipe "gitlab::database_#{gitlab['database_adapter']}"