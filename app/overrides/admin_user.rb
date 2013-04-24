Deface::Override.new(:virtual_path => "spree/admin/users/_form",
                     :name         => "admin_user_form_subscription",
                     :insert_after => "[data-hook=admin_user_form_fields]",
                     :partial      => "spree/admin/users/subscription_form")

Deface::Override.new(:virtual_path => "spree/admin/users/show",
                     :name         => "admin_user_show_subscription",
                     :insert_after => "table tr:last",
                     :partial      => "spree/admin/users/subscription")
