bundle check || bundle install

bundle exec rails db:create db:migrate

rm -f tmp/pids/server.pid && bundle exec rails s -p 3000 -b '0.0.0.0'
