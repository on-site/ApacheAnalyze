class SourcesController < ApplicationController
  def show
    @source = Source.from_file params[:id].to_i, params[:filename]
  end

  def index
    @sources = Source.everything
  end

  def destroy
    source = Source.from_file params[:id].to_i, params[:filename]
    source.delete_file! if params[:delete] == "true"
    source.drop_data! if params[:drop] == "true"
    redirect_to sources_path
  end

  def create
    if params[:filename].present?
      Source.load! params[:filename]
    elsif params[:upload_file].present?
      Source.upload! params[:upload_file]
    end

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
