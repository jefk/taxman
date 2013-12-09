class DividendData
  attr_reader :dividends

  def initialize(stream)
    @dividends = {}
    stream.each do |line|
      date, dividend = line.strip.split('$')
      @dividends[to_time(date)] = dividend.to_f
    end
  end

  private

  def to_time(datestr)
    month, day, year = datestr.split
    day.gsub!(',', '')
    Time.mktime(year.to_i, month, day.to_i)
  end
end
