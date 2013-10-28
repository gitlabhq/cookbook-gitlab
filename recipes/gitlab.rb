#
# Cookbook Name:: gitlab
# Recipe:: gitlab
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

## Configure it
### Copy the example GitLab config
template File.join(gitlab['path'], 'config', 'gitlab.yml') do
  source "gitlab.yml.erb"
  user gitlab['user']
  group gitlab['group']
  variables({
    :host => gitlab['host'],
    :port => gitlab['port'],
    :user => gitlab['user'],
    :email_from => gitlab['email_from'],
    :support_email => gitlab['support_email'],
    :satellites_path => gitlab['satellites_path'],
    :repos_path => gitlab['repos_path'],
    :shell_path => gitlab['shell_path']
  })
end

### Make sure GitLab can write to the log/ and tmp/ directories
%w{log tmp}.each do |path|
  directory File.join(gitlab['path'], path) do
    owner gitlab['user']
    group gitlab['group']
    mode 0755
  end
end

### Create directory for satellites
directory gitlab['satellites_path'] do
  owner gitlab['user']
  group gitlab['group']
end

### Create directories for sockets/pids and make sure GitLab can write to them
%w{tmp/pids tmp/sockets}.each do |path|
  directory File.join(gitlab['path'], path) do
    owner gitlab['user']
    group gitlab['group']
    mode 0755
  end
end

### Create public/uploads directory otherwise backup will fail
%w{public/uploads}.each do |path|
  directory File.join(gitlab['path'], path) do
    owner gitlab['user']
    group gitlab['group']
    mode 0755
  end
end

### Copy the example Unicorn config
template File.join(gitlab['path'], "config", "unicorn.rb") do
  source "unicorn.rb.erb"
  user gitlab['user']
  group gitlab['group']
  variables({
    :path => gitlab['path']
  })
end

### Copy the example Rack attack config
remote_file "rack_attack.rb" do
  path File.join(gitlab['path'], "config", "initializers", "rack_attack.rb")
  source "https://raw.github.com/gitlabhq/gitlabhq/#{gitlab['revision']}/config/initializers/rack_attack.rb.example"
  user gitlab['user']
  group gitlab['group']
end

### Uncomment a line in application.rb
bash "Uncomment a line in application.rb" do
  code <<-EOS
    sed -i "/# config.middleware.use Rack::Attack/ s/# *//" "#{File.join(gitlab['path'], "config", "application.rb")}"
  EOS
  user gitlab['user']
  group gitlab['group']
end


### Configure Git global settings for git user, useful when editing via web
bash "git config" do
  code <<-EOS
    git config --global user.name "GitLab"
    git config --global user.email "gitlab@#{gitlab['host']}"
    git config --global core.autocrlf input
  EOS
  user gitlab['user']
  group gitlab['group']
  environment('HOME' => gitlab['home'])
end

## Configure GitLab DB settings
template File.join(gitlab['path'], "config", "database.yml") do
  source "database.yml.#{gitlab['database_adapter']}.erb"
  user gitlab['user']
  group gitlab['group']
  variables({
    :user => gitlab['user'],
    :password => gitlab['database_password']
  })
end

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

### db:setup
gitlab['environments'].each do |environment|
  ### db:setup
  file_setup = File.join(gitlab['home'], ".gitlab_setup_#{environment}")
  file_setup_old = File.join(gitlab['home'], ".gitlab_setup")
  execute "rake db:setup" do
    command <<-EOS
      PATH="/usr/local/bin:$PATH"
      bundle exec rake db:setup RAILS_ENV=#{environment}
    EOS
    cwd gitlab['path']
    user gitlab['user']
    group gitlab['group']
    not_if {File.exists?(file_setup) || File.exists?(file_setup_old)}
  end

  file file_setup do
    owner gitlab['user']
    group gitlab['group']
    action :create
  end

  ### db:migrate
  file_migrate = File.join(gitlab['home'], ".gitlab_migrate_#{environment}")
  file_migrate_old = File.join(gitlab['home'], ".gitlab_migrate")
  execute "rake db:migrate" do
    command <<-EOS
      PATH="/usr/local/bin:$PATH"
      bundle exec rake db:migrate RAILS_ENV=#{environment}
    EOS
    cwd gitlab['path']
    user gitlab['user']
    group gitlab['group']
    not_if {File.exists?(file_migrate) || File.exists?(file_migrate_old)}
  end

  file file_migrate do
    owner gitlab['user']
    group gitlab['group']
    action :create
  end

  ### db:seed_fu
  file_seed = File.join(gitlab['home'], ".gitlab_seed_#{environment}")
  file_seed_old = File.join(gitlab['home'], ".gitlab_seed")
  execute "rake db:seed_fu" do
    command <<-EOS
      PATH="/usr/local/bin:$PATH"
      bundle exec rake db:seed_fu RAILS_ENV=#{environment}
    EOS
    cwd gitlab['path']
    user gitlab['user']
    group gitlab['group']
    not_if {File.exists?(file_seed) || File.exists?(file_seed_old)}
  end

  file file_seed do
    owner gitlab['user']
    group gitlab['group']
    action :create
  end
end

case gitlab['env']
when 'production'
  ## Install Init Script
  remote_file "init.d" do
    source "https://raw.github.com/gitlabhq/gitlabhq/#{gitlab['revision']}/lib/support/init.d/gitlab"
    path "/etc/init.d/gitlab"
    mode 0755
  end

  bash "Set the correct credentials" do
    code <<-EOS
      sed -i "s/app_root=\"\/home\/git\/gitlab\"/app_root=\""#{gitlab['path']}"\"/" /etc/init.d/gitlab
      sed -i "s/app_user=\"git\"/app_user=\""#{gitlab['user']}"\"/" /etc/init.d/gitlab
    EOS
  end

  ## Start Your GitLab Instance
  service "gitlab" do
    supports :start => true, :stop => true, :restart => true, :status => true
    action :enable
  end

  file File.join(gitlab['home'], ".gitlab_start") do
    owner gitlab['user']
    group gitlab['group']
    action :create_if_missing
    notifies :start, "service[gitlab]"
  end
else
  ## For execute javascript test
  include_recipe "phantomjs"
end
