#
# Cookbook Name:: gitlab
# Recipe:: ruby
#
gitlab = node['gitlab']

# Merge environmental variables
gitlab = Chef::Mixin::DeepMerge.merge(gitlab,gitlab[gitlab['env']])

# 2. Ruby
# Do not rely on system installed ruby packages
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
