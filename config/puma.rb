if ENV['RAILS_ENV'] == "production"
	stdout_redirect 'log/puma.log', 'log/puma_error.log', true
	pidfile 'tmp/pids/puma.pid'
	state_path 'tmp/pids/puma.state'
	environment 'production'
else
	environment 'development'
	# bind 'tcp://0.0.0.0:3000' # allows remote connections
end

workers 2
threads 5, 5
port 3000