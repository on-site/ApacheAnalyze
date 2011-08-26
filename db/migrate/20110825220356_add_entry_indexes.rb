class AddEntryIndexes < ActiveRecord::Migration
  def self.up
    add_index :entries, [:source_id, :parsed, :access_time]
    add_index :entries, [:access_time]
  end

  def self.down
    remove_index :entries, [:source_id, :parsed, :access_time]
    remove_index :entries, [:access_time]
  end
end
