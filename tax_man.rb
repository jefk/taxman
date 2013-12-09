require_relative 'price_data'
require_relative 'dividend_data'

class TaxMan
  attr_reader :prices, :purchases

  def initialize(price_data: nil, div_data: nil)
    prices_without_dividends = PriceData.new(price_data).prices
    dividends = DividendData.new(div_data).dividends
    set_prices(prices_without_dividends, dividends)
  end

  def estimate_average_cost(purchase_date:nil, purchase_price:nil)
    first_entry = {
      new_shares: 1.0,
      date: purchase_date,
      price: purchase_price,
    }
    @purchases = [first_entry]
    build_purchase_history
    average_cost
  end

  private

  def average_cost
    total_cost / total_shares
  end

  def total_cost
    purchases.reduce(0) do |sum, purchase|
      sum + purchase[:price] * purchase[:new_shares]
    end
  end

  def total_shares
    purchases.reduce(0) do |sum, purchase|
      sum + purchase[:new_shares]
    end
  end

  def build_purchase_history
    cumulative_shares = initial_shares

    prices.each do |date, record|
      next if date < buy_date
      next unless record[:dividend]

      purchase_price = record[:price] || record[:most_recent_price]
      new_shares = (cumulative_shares * record[:dividend]) / purchase_price
      cumulative_shares += new_shares

      @purchases << {
        date: date,
        price: purchase_price,
        new_shares: new_shares,
      }
    end
  end

  def buy_date
    @buy_date ||= purchases.first[:date]
  end

  def initial_shares
    @initial_shares ||= purchases.first[:new_shares]
  end

  def set_prices(prices_without_dividends, dividends)
    @prices = {}
    dates = (prices_without_dividends.keys + dividends.keys).sort
    most_recent_price = nil

    dates.each do |date|
      most_recent_price = prices_without_dividends[date] if prices_without_dividends[date]
      @prices[date] = {
        price: prices_without_dividends[date],
        most_recent_price: most_recent_price,
        dividend: dividends[date],
      }
    end
  end

end

irs = TaxMan.new price_data: open('price.data'), div_data: open('div.data')

purchase_date = Time.mktime(1983, 'Aug', 6)
puts irs.estimate_average_cost purchase_date:purchase_date, purchase_price:2.0084
