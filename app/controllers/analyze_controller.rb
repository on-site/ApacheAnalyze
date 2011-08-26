class AnalyzeController < ApplicationController
  VALID_TYPES = [:histogram]

  def index
    @sources = Source.with_parsed
    @min_access_time = Entry.minimum :access_time
    @max_access_time = Entry.maximum :access_time
  end

  def histogram
  end

  def load
    type = params[:visualization_type].to_sym
    raise "Invalid type #{type}" unless VALID_TYPES.include? type
    session[:sources] = params[:sources]
    session[:date_from] = params[:date_from]
    session[:date_to] = params[:date_to]
    redirect_to :action => type
  end
end
