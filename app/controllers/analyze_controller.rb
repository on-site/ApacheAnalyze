class AnalyzeController < ApplicationController
  VALID_TYPES = [:histogram]

  before_filter :prepare_options, :only => VALID_TYPES

  def index
    @all_sources = Source.with_parsed

    if session[:sources]
      @sources = session[:sources].map &:to_i
    else
      @sources = @all_sources.map &:id
    end

    @min_access_time = session[:date_from] || Entry.minimum(:access_time)
    @max_access_time = session[:date_to] || Entry.maximum(:access_time)
  end

  def histogram
    @histogram = Entry.histogram @options
  end

  def load
    type = params[:visualization_type].to_sym
    raise "Invalid type #{type}" unless VALID_TYPES.include? type
    session[:sources] = params[:sources] || []
    session[:date_from] = params[:date_from]
    session[:date_to] = params[:date_to]
    redirect_to :action => type
  end

  private
  def prepare_options
    @options = AnalyzeOptions.new session
  end
end
