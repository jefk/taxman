class PriceData
  attr_reader :prices

  SECONDS_IN_WEEK = 60 * 60 * 24 * 7

  def initialize(stream)
    @prices = {}
    stream.each do |line|
      @line = line
      date = get_date
      next unless date

      @prices[date] = price
    end
  end

  private
  attr_accessor :line, :last_absolute_date

  def price
    line.split(',')[1].to_f
  end

  def get_date
    if absolute_date?
      get_absolute
    elsif relative_date?
      get_relative
    end
  end

  def get_absolute
    unix_time = line.split(',').first[1..-1].to_i
    @last_absolute_date = Time.at(unix_time)
  end

  def get_relative
    last_absolute_date + line.split(',').first.to_i * SECONDS_IN_WEEK
  end

  def absolute_date?
    line =~ /^a/
  end

  def relative_date?
    line =~ /^\d/
  end
end
