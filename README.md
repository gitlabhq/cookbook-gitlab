GitLab Cookbook
===============

Chef cookbook with recipes to install GitLab.

* GitLab: 6.2
* GitLab Shell: 1.7.4
* Ruby: 2.0.0p247
* Redis: 2.6.13
* Git: 1.7.12
* Nginx: 1.1.19
* PostgreSQL: 9.1.9
* MySQL: 5.5.31

## Requirements

* [Berkshelf](http://berkshelf.com/)
* [Vagrant](http://www.vagrantup.com/)

### Vagrant Plugin

* [vagrant-berkshelf](https://github.com/RiotGames/vagrant-berkshelf)
* [vagrant-omnibus](https://github.com/schisamo/vagrant-omnibus)
* [vagrant-aws](https://github.com/mitchellh/vagrant-aws)


### Platform:

* Ubuntu (12.04, 12.10)
* CentOS (6.4)


## Installation

### Vagrant

#### VirtualBox 

```bash
$ gem install berkshelf
$ vagrant plugin install vagrant-berkshelf
$ vagrant plugin install vagrant-omnibus
$ git clone git://github.com/gitlabhq/cookbook-gitlab ./gitlab
$ cd ./gitlab/
$ vagrant up
```

#### Amazon Web Services

Creates an AWS instance.

```bash
$ gem install berkshelf
$ vagrant plugin install vagrant-berkshelf
$ vagrant plugin install vagrant-omnibus
$ vagrant plugin install vagrant-aws
$ vagrant box add dummy https://github.com/mitchellh/vagrant-aws/raw/master/dummy.box
$ git clone git://github.com/gitlabhq/cookbook-gitlab ./gitlab
$ cd ./gitlab/
$ cp ./example/Vagrantfile_aws ./Vagrantfile
```
Fill in the AWS credentials under the aws section in Vagrantfile and then run:

```bash
$ vagrant up --provider=aws
```

HostName setting.

```bash
$ vagrant ssh-config | awk '/HostName/ {print $2}'
$ editor ./Vagrantfile
$ vagrant provision
```

#### AWS OpsWorks

* Create a custom layer or use a predefined `Rails app server` layer.
* Edit the layer
* Under `Custom Chef Recipes` supply the url to the cookbook repository
* Under `Setup` write `gitlab::setup` and press the + sign to add
* Under `Deploy` write `gitlab::deploy` and press the + sign to add
* Save changes made to the layer (Scroll to the bottom of the page for the Save button)
* Go to Instances
* Create a new instance(or use an existing one) and add the previously edited layer

### chef-solo

You can easily install your server even if you don't have chef-server by using chef-solo.
This is useful if you have only one server that you have to maintain so having chef-server would be an overkill.
**Note** Following steps assume that you have git, ruby(> 1.8.7) and rubygems installed.
To get GitLab installed do:

```bash
$ gem install berkshelf
$ cd /tmp
$ curl -LO https://www.opscode.com/chef/install.sh && sudo bash ./install.sh -v 11.4.4
$ git clone https://github.com/gitlabhq/cookbook-gitlab.git /tmp/gitlab
$ cd /tmp/gitlab
$ berks install --path /tmp/cookbooks
$ cat > /tmp/solo.rb << EOF
cookbook_path    ["/tmp/cookbooks/", "/tmp/gitlab/"]
log_level        :debug
EOF
$ cat > /tmp/solo.json << EOF
{"gitlab": {"host": "HOSTNAME", "url": "http://FQDN:80/"}, "recipes":["gitlab::default"]}
EOF
$ chef-solo -c /tmp/solo.rb -j /tmp/solo.json
```
Chef-solo command should start running and setting up GitLab and it's dependencies.
No errors should be reported and at the end of the run you should be able to navigate to the
`HOSTNAME` you specified using your browser and connect to the GitLab instance.

## Usage

To override default settings of this cookbook you have to supply a json to the node.

```json
{
  "postfix": {
    "mail_type": "client",
    "myhostname": "mail.example.com",
    "mydomain": "example.com",
    "myorigin": "mail.example.com",
    "smtp_use_tls": "no"
  },
  "postgresql": {
    "password": {
      "postgres": "psqlpass"
    }
  },
  "mysql": {
    "server_root_password": "rootpass",
    "server_repl_password": "replpass",
    "server_debian_password": "debianpass"
  },
  "gitlab": {
    "host": "example.com",
    "url": "http://example.com/",
    "email_from": "gitlab@example.com",
    "support_email": "support@example.com",
    "database_adapter": "postgresql",
    "database_password": "datapass"
  },
  "run_list":[
    "postfix",
    "gitlab::default"
  ]
}
```

## Database

Default database for this cookbook is `mysql`.
To override default credentials for the database supply the following json to the node:

```json
{
  "mysql": {
    "server_root_password": "rootpass",
    "server_repl_password": "replpass",
    "server_debian_password": "debianpass"
  },
  "gitlab": {
    "database_password": "datapass"
  }
}
```

To use `postgresql` override default credentials by supplying the following json to the node:

```json
{
  "posgtresql": {
    "password": {
      "postgres": "psqlpass"
    }
  },
  "gitlab": {
    "database_adapter": "postgresql",
    "database_password": "datapass",
  }
}
```

## Recipes

### clone

Clones the GitLab repository. Recipe uses the attributes in `attributes/default.rb` and, depending on the environment set,
`attributes/development.rb` or `attributes/production.rb`.

### database_mysql

Use to setup mysql database. Available attributes are listed in `attributes/default.rb`.

### database_posgresql

Use to setup postgresql database. Available attributes are listed in `attributes/default.rb`.

### default

Default recipe, it includes two recipes: `setup` and `deploy`. Default recipe is being used to do the complete GitLab installation.

### deploy

Used to clone, configure, setup and start a GitLab instance. `deploy` recipe can be used with AWS OpsWorks to deploy GitLab to an instance.
To use with AWS OpsWorks:

1. Use a preset `Rails App Server` layer or create a custom one
1. Edit the layer
1. Under section `Custom Chef Recipes` and `Deploy` fill in `gitlab::deploy` and save

NOTE: Must be used in combination with `gitlab::setup` recipe.

### gems

This recipe decides what will be included and what will be ommited from the bundle install command and then it runs the bundle install.
Inclusion or exclusion is decided based on the database selected and environment, using attributes in `attributes/default.rb`

### git

Installs packages required for git and compiles it from source. Uses attributes provided in `attributes/git.rb`.

### gitlab_shell_clone

Clones the gitlab-shell repository. Recipe uses the attributes in `attributes/default.rb` and, depending on the environment set,
`attributes/development.rb` or `attributes/production.rb`.

### gitlab_shell_install
Creates a gitlab-shell config.yml from attributes in `attributes/default.rb` and, depending on the environment set,
`attributes/development.rb` or `attributes/production.rb`. Runs `gitlab-shell` install script and install it.

### install
Creates a gitlab config.yml, database.yml from attributes in `attributes/default.rb` and, depending on the environment set,
`attributes/development.rb` or `attributes/production.rb`. Creates GitLab required directories and sets permissions. Copies the example files
to their locations. Runs `db:setup`, `db:migrate`, `db:seed_fu` to prepare selected database for GitLab.

### nginx
Installs and configures nginx for usage.

### packages
Installs all GitLab dependency packages supplied in `attributes/default.rb`.

### ruby
Compiles ruby from source based on attributes in `attributes/default.rb`.

### setup

Includes `packages`, `ruby`, `users` and database recipes to prepare the server for GitLab.
`setup` recipe can be used with AWS OpsWorks to setup requirements for GitLab.
To use with AWS OpsWorks:

1. Use a preset `Rails App Server` layer or create a custom one
1. Edit the layer
1. Under section `Custom Chef Recipes` and `Setup` fill in `gitlab::setup` and save

NOTE: Must be used in combination with `gitlab::deploy` recipe.

### start

Enables gitlab service and starts GitLab.

### users

Creates a GitLab user called `git`.


## Done!

`http://localhost:8080/` or your server for your first GitLab login.

```
admin@local.host
5iveL!fe
```

## Development

To use this cookbook to provision a development vagrant box add the following json to the `Vagrantfile` under the `chef.json` section:

```json
***
"gitlab": {
    "env": "development",
  }
```

## Testing

First install the necessary gems

```bash
bundle install
```
To check for syntax errors run foodcritic:

```bash
foodcritic .
```
assuming that you are inside cookbook-gitlab directory.

Run tests with:

```bash
bundle exec rspec
```

## Acknowledgement

This cookbook was based on work by [ogom](https://github.com/ogom/cookbook-gitlab). Thank you ogom!

## Contributing

We welcome all contributions.
Proper Merge request must:

1. Explain in description what it does
1. Explain which platforms it is run on and which platforms are untested
1. Contain passing `chefspec` tests


## Links

* [GitLab Installation](https://github.com/gitlabhq/gitlabhq/blob/master/doc/install/installation.md)
* [Qiita Document](http://qiita.com/items/6491a268bfc95d0a5be4)


## License

* MIT
