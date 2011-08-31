class AnalyzeController < ApplicationController
  VALID_TYPE_VALUES = {
    :average_duration_histogram => "Average Duration Histogram",
    :max_duration_histogram => "Max Duration Histogram",
    :request_histogram => "Request Histogram",
    :url_average_duration_histogram => "URL Average Duration Histogram",
    :url_max_duration_histogram => "URL Max Duration Histogram",
    :url_total_duration_histogram => "URL Total Duration Histogram",
    :url_histogram => "URL Histogram"
  }
  VALID_TYPES = VALID_TYPE_VALUES.keys

  before_filter :prepare_options, :only => VALID_TYPES

  def index
    @all_sources = Source.with_parsed
    @sources = @all_sources.map &:id
    @min_access_time = Entry.minimum(:access_time)
    @max_access_time = Entry.maximum(:access_time)
  end

  def average_duration_histogram
    @histogram = Entry.average_duration_histogram @options
  end

  def max_duration_histogram
    @histogram = Entry.max_duration_histogram @options
  end

  def request_histogram
    @histogram = Entry.request_histogram @options
  end

  def url_average_duration_histogram
    @histogram = Entry.url_average_duration_histogram @options
    @max_value = @histogram.first.value_id.to_f
  end

  def url_max_duration_histogram
    @histogram = Entry.url_max_duration_histogram @options
    @max_value = @histogram.first.value_id.to_f
  end

  def url_total_duration_histogram
    @histogram = Entry.url_total_duration_histogram @options
    @max_value = @histogram.first.value_id.to_f
  end

  def url_histogram
    @histogram = Entry.url_histogram @options
    @max_value = @histogram.first.value_id.to_f
  end

  def load
    type = params[:visualization_type].to_sym
    raise "Invalid type #{type}" unless VALID_TYPES.include? type
    redirect_to :action => type, :sources => params[:sources], :date_from => params[:date_from], :date_to => params[:date_to], :histogram_detail => params[:histogram_detail]
  end

  private
  def prepare_options
    @options = AnalyzeOptions.new params
  end
end
