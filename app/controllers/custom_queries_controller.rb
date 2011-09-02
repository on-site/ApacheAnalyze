class CustomQueriesController < ApplicationController
  before_filter :prepare_query, :only => [:run, :show, :destroy]

  def index
    @queries = CustomQuery.order(:name).all
  end

  def run
    @query.name = params[:name] if params[:name].present?
    @query.query = params[:query] if params[:query].present?
    @results = @query.run
  end

  def update
    @query = CustomQuery.find params[:id]

    save_and_run do |name, query|
      @query.name = name
      @query.query = query
      @query.save!
      @query
    end
  end

  def create
    save_and_run do |name, query|
      CustomQuery.create! :name => name, :query => query
    end
  end

  def destroy
    @query.destroy
    redirect_to custom_queries_path
  end

  private
  def save_and_run
    save = params[:save] == "true"
    run = params[:run] == "true"
    name = params[:name]
    query = params[:query]

    if !save && !run
      flash[:notice] = "Nothing saved, nothing ran, nothing gained."
      return redirect_to new_custom_query_path(:name => name, :query => query)
    end

    if save
      custom_query = yield name, query
      flash[:notice] = "Saved the query."
    end

    if run && custom_query
      redirect_to run_custom_query_path(custom_query.id)
    elsif run && @query
      redirect_to run_custom_query_path(@query.id, :name => name, :query => query)
    elsif run
      redirect_to run_custom_query_path(-1, :name => name, :query => query)
    else
      redirect_to custom_query_path(custom_query.id)
    end
  end

  def prepare_query
    @id = params[:id].to_i

    if @id == -1
      @query = CustomQuery.new :name => params[:name], :query => params[:query]
    else
      @query = CustomQuery.find @id
    end
  end
end
