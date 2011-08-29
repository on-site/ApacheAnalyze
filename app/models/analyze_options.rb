class AnalyzeOptions
  attr_accessor :sources, :date_from, :date_to, :histogram_count
  SHORT_TIME_FORMAT = "%H:%M:%S %m/%d/%y"

  def initialize(session)
    self.sources = (session[:sources] || Source.with_parsed.map(&:id)).map(&:to_i)

    if session[:date_from]
      self.date_from = DateTime.parse session[:date_from]
    else
      self.date_from = Entry.minimum :access_time
    end

    if session[:date_to]
      self.date_to = DateTime.parse session[:date_to]
    else
      self.date_to = Entry.maximum :access_time
    end

    self.histogram_count = 100
  end

  def date_ranges
    results = []

    step_dates histogram_count do |x, y|
      results << (x..y)
    end

    results
  end

  def json_date_ranges
    date_ranges.map do |x|
      [x.begin.strftime(SHORT_TIME_FORMAT), x.end.strftime(SHORT_TIME_FORMAT)]
    end.to_json
  end

  def json_full_date_ranges
    date_ranges.map do |x|
      [x.begin.to_s, x.end.to_s]
    end.to_json
  end

  private
  def step_dates(count)
    last = nil
    t1 = date_from.to_f
    t2 = date_to.to_f
    step_value = (t2 - t1) / count.to_f

    (t1..t2).step step_value do |x|
      yield Time.at(last), Time.at(x) if last
      last = x
    end
  end
end
