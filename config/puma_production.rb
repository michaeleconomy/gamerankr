stdout_redirect 'log/puma.log', 'log/puma_error.log', true
pidfile 'tmp/pids/puma.pid'
state_path 'tmp/pids/puma.state'
environment 'production'
port 3000