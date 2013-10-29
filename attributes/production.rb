# User
default['gitlab']['production']['user'] = "git" # Changing default user may have unintended consequences. Update init script if you change this 
default['gitlab']['production']['group'] = "git"
default['gitlab']['production']['home'] = "/home/git"

# GitLab shell
default['gitlab']['production']['shell_path'] = "/home/git/gitlab-shell"

# GitLab hq
default['gitlab']['production']['revision'] = "6-2-stable"
default['gitlab']['production']['path'] = "/home/git/gitlab" # Changing default path may have unintended consequences. Update init script if you change this

# GitLab shell config
default['gitlab']['production']['repos_path'] = "/home/git/repositories"

# GitLab hq config
default['gitlab']['production']['satellites_path'] = "/home/git/gitlab-satellites"

# Setup environments
default['gitlab']['production']['environments'] = %w{production}
