class AnalyzeController < ApplicationController
  VALID_TYPES = [:histogram]

  before_filter :prepare_options, :only => VALID_TYPES

  def index
    @all_sources = Source.with_parsed
    @sources = @all_sources.map &:id
    @min_access_time = Entry.minimum(:access_time)
    @max_access_time = Entry.maximum(:access_time)
  end

  def histogram
    @histogram = Entry.histogram @options
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
    redirect_to :action => type
  end

  private
  def prepare_options
    @options = AnalyzeOptions.new session
  end
end
