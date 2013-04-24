Deface::Override.new(:virtual_path => "spree/shared/_user_form",
                     :name         => "user_form_subscription",
                     :insert_after => "[data-hook=signup_below_password_fields]",
                     :partial      => "spree/shared/user_subscription")
