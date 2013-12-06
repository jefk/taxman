# open('price.data').each do |line|
#   next unless line =~ /^a/
#   idate = line.split(',').first[1..-1].to_i
#   puts Time.at(idate).wday

# end

class DateData
  attr_reader :stream, :line, :last_absolute_date

  SECONDS_IN_WEEK = 60 * 60 * 24 * 7

  def initialize(stream: nil)
    @stream = stream
  end

  def dates
    stream.each do |line|
      @line = line
      # next unless date

      p date
    end
  end

  def date
    if absolute_date?
      p 'a'
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

stuff = DateData.new stream: File.open('price.data')
stuff.dates
