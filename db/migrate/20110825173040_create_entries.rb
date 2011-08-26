class CreateEntries < ActiveRecord::Migration
  def self.up
    create_table :entries do |t|
      t.integer :source_id, :null => false
      t.string :original, :limit => 512, :null => false
      t.boolean :parsed, :null => false, :default => false
      t.string :client_ip
      t.datetime :access_time
      t.float :duration
      t.string :http_request
      t.string :http_method
      t.string :http_url
      t.integer :status_code
      t.string :referrer
      t.string :user_agent

      t.timestamps
    end

    create_table :sources do |t|
      t.string :filename, :null => false

      t.timestamps
    end

    add_index :sources, [:filename], :unique => true
  end

  def self.down
    drop_table :entries
    drop_table :sources
  end
end
