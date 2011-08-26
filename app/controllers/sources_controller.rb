class SourcesController < ApplicationController
  def show
    @source = Source.from_file params[:id].to_i, params[:filename]
  end

  def index
    @sources = Source.everything
  end

  def create
    Source.load! params[:filename]
    redirect_to sources_path
  end

  def parse
    Source.find(params[:id]).parse! params[:regex], params[:groups]
    redirect_to sources_path
  end

  def reparse
    Source.find(params[:id]).parse! params[:regex], params[:groups], :force => true
    redirect_to sources_path
  end
end
