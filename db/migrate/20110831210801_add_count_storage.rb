class AddCountStorage < ActiveRecord::Migration
  def self.up
    add_column :sources, :count_entries, :integer
    add_column :sources, :count_parsed_entries, :integer
    add_column :sources, :count_unparsed_entries, :integer
  end

  def self.down
    remove_columns :sources, :count_entries, :count_parsed_entries, :count_unparsed_entries
  end
end
