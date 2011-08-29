class CreateMoreEntriesIndexes < ActiveRecord::Migration
  def self.up
    add_index :entries, [:source_id]
    add_index :entries, [:source_id, :parsed]
  end

  def self.down
    remove_index :entries, [:source_id]
    remove_index :entries, [:source_id, :parsed]
  end
end
