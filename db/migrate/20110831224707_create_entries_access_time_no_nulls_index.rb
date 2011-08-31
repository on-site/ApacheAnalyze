class CreateEntriesAccessTimeNoNullsIndex < ActiveRecord::Migration
  def self.up
    if connection.adapter_name != "SQLite"
      execute "CREATE INDEX entries_access_time_no_nulls ON entries(access_time) WHERE access_time IS NOT NULL"
    end
  end

  def self.down
    if connection.adapter_name != "SQLite"
      execute "DROP INDEX entries_access_time_no_nulls"
    end
  end
end
