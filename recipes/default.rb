#
# Cookbook Name:: gitlab
# Recipe:: default
#

# Does the setup of various GitLab dependencies
include_recipe "gitlab::setup"

# Does the configuration and install of GitLab
include_recipe "gitlab::deploy"