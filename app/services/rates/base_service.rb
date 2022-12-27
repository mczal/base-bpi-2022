# frozen_string_literal: true
require 'selenium-webdriver'
require 'nokogiri'
require 'capybara'
require 'webdrivers/chromedriver'

module Rates
  class BaseService < ::BaseService
    def teardown_setup
      browser.quit
    end

    protected
      def browser
        # memoization searching
        @browser ||= Capybara.current_session
      end

      def driver
        @driver ||= browser.driver.browser
      end

      def docs
        @doc ||= Nokogiri::HTML(driver.page_source);
      end

      def visit
        browser.visit(url)
        wait_until selector
      end

      def wait_until s
        browser.has_css?(s)
      end

      def save_kurs
        Rate.create!(
          origin: origin,
          buying: @buying_rate,
          selling: @selling_rate,
          published_date: @published_date
        )
      end
  end
end
