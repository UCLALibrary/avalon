# frozen_string_literal: true
server 'avalon-test.library.ucla.edu', user: 'deploy', roles: [:web, :app, :db, :resque_worker, :resque_scheduler]
