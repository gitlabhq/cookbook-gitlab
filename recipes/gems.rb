#
# Cookbook Name:: gitlab
# Recipe:: gems
#

gitlab = node['gitlab']

# Merge environmental variables
gitlab = Chef::Mixin::DeepMerge.merge(gitlab,gitlab[gitlab['env']])

## Install Gems
gem_package "charlock_holmes" do
  version "0.6.9.4"
  options "--no-ri --no-rdoc"
end

template File.join(gitlab['home'], ".gemrc") do
  source "gemrc.erb"
  user gitlab['user']
  group gitlab['group']
  notifies :run, "execute[bundle install]", :immediately
end

### without
bundle_without = []
case gitlab['database_adapter']
when 'mysql'
  bundle_without << 'postgres'
  bundle_without << 'aws'
when 'postgresql'
  bundle_without << 'mysql'
  bundle_without << 'aws'
end

case gitlab['env']
when 'production'
  bundle_without << 'development'
  bundle_without << 'test'
else
  bundle_without << 'production'
end

execute "bundle install" do
  command <<-EOS
    PATH="/usr/local/bin:$PATH"
    #{gitlab['bundle_install']} --without #{bundle_without.join(" ")}
  EOS
  cwd gitlab['path']
  user gitlab['user']
  group gitlab['group']
  action :nothing
end