#set :deploy_to, "/svc/tweet" # defaults to "/u/apps/#{application}"
#set :user, "tweet"            # defaults to the currently logged in user
set :daemon_env, 'production'

set :domain, '74.86.131.195'
server domain
