class SourcesController < ApplicationController
  def index
    @sources = Source.everything
  end
end
