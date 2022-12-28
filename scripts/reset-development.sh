#!/bin/bash
bundle exec rails db:migrate:reset
bundle exec rails user:seed
bundle exec rails assets:clobber assets:precompile
bundle exec rails rates:scrap:bank_of_indonesia
bundle exec rails rates:scrap:ministry_of_finance
