class AddUserParams < ActiveRecord::Migration
  def self.up
      add_column :users, :screen_name, :string
      add_column :users, :email, :string
      add_column :users, :password, :string
      
  end

  def self.down
      remove_column :users, :screen_name
      remove_column :users, :email
      remove_column :users, :password

  end
end
