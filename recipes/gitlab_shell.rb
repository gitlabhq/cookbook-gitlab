#
# Cookbook Name:: gitlab
# Recipe:: gitlab_shell
#

gitlab = node['gitlab']

# Merge environmental variables
gitlab = Chef::Mixin::DeepMerge.merge(gitlab,gitlab[gitlab['env']])

## Edit config and replace gitlab_url
template File.join(gitlab['shell_path'], "config.yml") do
  source "gitlab_shell.yml.erb"
  user gitlab['user']
  group gitlab['group']
  variables({
    :user => gitlab['user'],
    :home => gitlab['home'],
    :url => gitlab['url'],
    :repos_path => gitlab['repos_path'],
    :redis_path => gitlab['redis_path'],
    :redis_host => gitlab['redis_host'],
    :redis_port => gitlab['redis_port'],
    :namespace => gitlab['namespace']
  })
  notifies :run, "execute[gitlab-shell install]", :immediately
end

## Do setup
execute "gitlab-shell install" do
  command <<-EOS
    PATH="/usr/local/bin:$PATH"
    ./bin/install
  EOS
  cwd gitlab['shell_path']
  user gitlab['user']
  group gitlab['group']
  action :nothing
  notifies :create, "link[create symlink for gitlab-shell path for development]", :immediately
end

# Symlink gitlab-shell to vagrant home, so that sidekiq can use gitlab shell commands
link "create symlink for gitlab-shell path for development" do
  target_file "#{gitlab['home']}/gitlab-shell"
  to gitlab['shell_path']
  not_if { gitlab['env'] == "production" }
end
