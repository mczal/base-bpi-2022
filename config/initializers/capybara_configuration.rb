# Capybara.register_driver :selenium do |app|
  # Capybara::Selenium::Driver.new(app, browser: :chrome)
# end
# Capybara.javascript_driver = :chrome
# Capybara.configure do |config|
  # config.default_max_wait_time = 10 # seconds
  # config.default_driver = :selenium_chrome_headless # :selenium
# end




opts = Selenium::WebDriver::Chrome::Options.new
# chrome_args = %w[--headless --no-sandbox --disable-gpu] #V1
# chrome_args = %w[--headless] # V2
chrome_args = []
chrome_args.each { |arg| opts.add_argument(arg)  }
Capybara.register_driver :custom_chrome_headless do |app|
  Capybara::Selenium::Driver.new(
     app,
     browser: :chrome,
     options: opts,
     desired_capabilities: Selenium::WebDriver::Remote::Capabilities.chrome({ "chromeOptions" => { "binary" => ENV.fetch('GOOGLE_CHROME_SHIM', nil) } })
  )
end
Capybara.javascript_driver = :custom_chrome_headless
Capybara.configure do |config|
  config.default_max_wait_time = 10 # seconds
  config.default_driver = :custom_chrome_headless # :selenium
end



# Capybara.javascript_driver = :selenium_chrome_headless
# Capybara.configure do |config|
  # config.default_max_wait_time = 60 # seconds
  # config.default_driver = :selenium_chrome_headless # :selenium
# end
