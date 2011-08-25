class SourcesController < ApplicationController
  def index
    @sources = Source.everything
  end

  def create
    Source.load! params[:filename]
    redirect_to sources_path
  end
end
