class AddServerAndParamsColumns < ActiveRecord::Migration
  def self.up
    add_column :entries, :http_query_string, :string
    add_column :entries, :server_name, :string, :limit => 64
  end

  def self.down
    remove_column :entries, :http_query_string
    remove_column :entries, :server_name
  end
end
