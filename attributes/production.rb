# User
default['gitlab']['production']['user'] = "git" # Do not change this attribute in production since some code from the GitLab repo such as init.d script assume it is git.
default['gitlab']['production']['group'] = "git"
default['gitlab']['production']['home'] = "/home/git"

# GitLab shell
default['gitlab']['production']['shell_path'] = "/home/git/gitlab-shell"

# GitLab hq
default['gitlab']['production']['revision'] = "6-2-stable"
default['gitlab']['production']['path'] = "/home/git/gitlab" # Do not change this attribute in production since some code from the GitLab repo such as init.d assume this path.

# GitLab shell config
default['gitlab']['production']['repos_path'] = "/home/git/repositories"

# GitLab hq config
default['gitlab']['production']['satellites_path'] = "/home/git/gitlab-satellites"

# Setup environments
default['gitlab']['production']['environments'] = %w{production}
