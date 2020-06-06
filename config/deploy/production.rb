server "159.203.176.100", port: 22, roles: [:web, :app, :db], primary: true
set :migration_role, :app