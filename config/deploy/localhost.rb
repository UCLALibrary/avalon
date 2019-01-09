# frozen_string_literal: true
server '127.0.0.1', user: 'deploy', roles: [:web, :app, :db, :resque_worker, :resque_scheduler]
