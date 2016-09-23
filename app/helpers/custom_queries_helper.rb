module CustomQueriesHelper
  def save_method
    if new?
      :post
    else
      :put
    end
  end

  def save_path
    if new?
      custom_queries_path
    else
      custom_query_path @query
    end
  end

  def run_path
    if new?
      run_custom_query_path -1, name: @query.name, query: @query.query
    else
      run_custom_query_path @query
    end
  end

  def new?
    @id == -1
  end

  def each_result_key
    @_result_keys ||= @results.first.keys.select { |x| x.kind_of? String }
    @_result_keys.each do |key|
      yield key
    end
  end
end
