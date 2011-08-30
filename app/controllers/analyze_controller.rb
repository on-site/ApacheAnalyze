class AnalyzeController < ApplicationController
  VALID_TYPE_VALUES = {
    :average_duration_histogram => "Average Duration Histogram",
    :max_duration_histogram => "Max Duration Histogram",
    :request_histogram => "Request Histogram",
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

  def url_histogram
    @histogram = Entry.url_histogram @options
    @max_value = @histogram.first.url_count.to_f
  end

  def load
    type = params[:visualization_type].to_sym
    raise "Invalid type #{type}" unless VALID_TYPES.include? type
    params[:sources] = nil if params[:sources].blank?
    params[:date_from] = nil if params[:date_from].blank?
    params[:date_to] = nil if params[:date_to].blank?
    session[:sources] = params[:sources] || session[:sources] || []
    session[:date_from] = params[:date_from] || session[:date_from]
    session[:date_to] = params[:date_to] || session[:date_to]
    session[:histogram_detail] = params[:histogram_detail] || session[:histogram_detail]
    redirect_to :action => type
  end

  private
  def prepare_options
    @options = AnalyzeOptions.new session
  end
end
