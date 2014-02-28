class CreateActions < ActiveRecord::Migration
  def change
    create_table :spree_chimpy_actions do |t|
      t.string   :email
      t.text     :request_params
      t.string   :euid
      t.string   :leid
      t.string   :action
      t.string   :source

      t.timestamps
    end
  end
end
