release: bundle exec rails db:migrate
web: bundle exec rails server -p $PORT
resque: QUEUE=* bundle exec rake resque:work
