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
    flash[:notice] = "Finished deleting"
    redirect_to sources_path
  end

  def create
    if params[:filename].present?
      options = {}

      if params[:parse] == "true"
        options[:regex] = params[:regex] || ""
        options[:groups] = params[:groups] || ""
      end

      Source.load! params[:filename], options
      flash[:notice] = "Finished loading"
    elsif params[:upload_file].present?
      Source.upload! params[:upload_file]
      flash[:notice] = "Finished uploading"
    end

    redirect_to sources_path
  end

  def parse
    Source.find(params[:id]).parse! params[:regex], params[:groups]
    flash[:notice] = "Finished parsing"
    redirect_to sources_path
  end

  def reparse
    Source.find(params[:id]).parse! params[:regex], params[:groups], :force => true
    flash[:notice] = "Finished reparsing"
    redirect_to sources_path
  end

  def recount
    Source.find(params[:id]).recalculate_counts!
    flash[:notice] = "Finished recounting"
    redirect_to sources_path
  end
end
