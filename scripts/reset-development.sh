#!/bin/bash
bundle exec rails db:migrate:reset
bundle exec rails user:seed
bundle exec rails assets:clobber assets:precompile
