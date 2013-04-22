class AddSubscribedToSpreeUsers < ActiveRecord::Migration
  def change
    change_table :spree_users do |t|
      t.boolean :subscribed
    end
  end
end
