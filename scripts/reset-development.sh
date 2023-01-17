#!/bin/bash
bundle exec rails db:migrate:reset
bundle exec rails user:seed
bundle exec rails banks:seed:populate


bundle exec rails rates:seed:bank_of_indonesia
bundle exec rails rates:seed:ministry_of_finance

bundle exec rails rates:scrap:bank_of_indonesia
bundle exec rails rates:scrap:ministry_of_finance

bundle exec rails approval_configurations:seed

# bundle exec rails assets:clobber assets:precompile
