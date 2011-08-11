#set :deploy_to, "/svc/tweet" # defaults to "/u/apps/#{application}"
#set :user, "tweet"            # defaults to the currently logged in user
set :daemon_env, 'staging'

set :domain, '127.0.0.1'
server domain
