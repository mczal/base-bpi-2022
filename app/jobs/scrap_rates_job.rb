class ScrapRatesJob < ApplicationJob
  queue_as :default

  def perform
    system './scripts/scrap-rates.sh'
  end
end
