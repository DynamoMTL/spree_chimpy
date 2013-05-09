class CreateSubscriber < ActiveRecord::Migration
  def change
    create_table :spree_hominid_subscribers do |t|
      t.string :email, null: false
      t.boolean :subscribed, default: true
      t.timestamps
    end
  end
end
