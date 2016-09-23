class CreateCustomQueriesTable < ActiveRecord::Migration
  def self.up
    create_table :custom_queries do |t|
      t.string :name, null: false
      t.text :query, null: false
    end
  end

  def self.down
    drop_table :custom_queries
  end
end
