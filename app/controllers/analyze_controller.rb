class AnalyzeController < ApplicationController
  def index
    @sources = Source.with_parsed
  end
end
