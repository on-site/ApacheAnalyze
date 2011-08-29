class AddUserAgentType < ActiveRecord::Migration
  def self.up
    add_column :entries, :user_agent_type, :string
  end

  def self.down
    remove_column :entries, :user_agent_type, :string
  end
end
