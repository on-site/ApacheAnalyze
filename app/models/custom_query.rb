class CustomQuery < ActiveRecord::Base
  def run
    connection.execute query
  end
end
