#!/bin/bash
xvfb-run -a bundle exec rails rates:scrap:bank_of_indonesia
xvfb-run -a bundle exec rails rates:scrap:ministry_of_finance
