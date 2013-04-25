class CreateOrderSources < ActiveRecord::Migration
  def change
    create_table :spree_hominid_order_sources do |t|
      t.references :order
      t.string :campaign_id, :email_id

      t.timestamps
    end
  end
end
