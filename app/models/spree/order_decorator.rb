Spree::Order.class_eval do
  has_one :source, class_name: 'Spree::Chimpy::OrderSource'

  register_update_hook :notify_mail_chimp

  def notify_mail_chimp
    if Spree::Chimpy.configured? and ((completed? && total_changed?) or canceled?)
      if self.user && self.user.subscribed?
        self.user.update_member_info
      else
        user = Spree.user_class.where(email: self.email, subscribed: true).first
        user.update_member_info if user
      end

      Spree::Chimpy.enqueue(:order, self) 
    end
  end

end
