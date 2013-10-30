#
# Cookbook Name:: gitlab
# Recipe:: initial
#

gitlab = node['gitlab']

# Merge environmental variables
gitlab = Chef::Mixin::DeepMerge.merge(gitlab,gitlab[gitlab['env']])

# 0. Initial Change
directory "/tmp" do
  mode 0777
end


# 1. Packages / Dependencies
include_recipe "apt" if platform?("ubuntu", "debian")
include_recipe "yum::epel" if platform?("centos")
include_recipe "gitlab::git"
include_recipe "redisio::install"
include_recipe "redisio::enable"

## Install the required packages.
gitlab['packages'].each do |pkg|
  package pkg
end


# 2. Ruby
include_recipe "ruby_build"

## Download and compile it:
ruby_build_ruby gitlab['ruby'] do
  prefix_path "/usr/local/"
end

## Install the Bundler Gem:
gem_package "bundler" do
  gem_binary "/usr/local/bin/gem"
  options "--no-ri --no-rdoc"
end

include_recipe "gitlab::users"
