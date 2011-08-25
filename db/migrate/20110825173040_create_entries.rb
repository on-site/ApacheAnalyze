class CreateEntries < ActiveRecord::Migration
  def self.up
    create_table :entries do |t|
      t.string :source, :null => false
      t.string :original, :limit => 512, :null => false
      t.string :client_ip
      t.datetime :access_time
      t.string :http_request
      t.integer :status_code

      t.timestamps
    end
  end

  def self.down
    drop_table :entries
  end
end
