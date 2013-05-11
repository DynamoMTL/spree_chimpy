namespace :spree_chimpy do
  desc 'sync all orders with mail chimp'
  task sync_orders: :environment do
    scope = Spree::Order.complete

    puts "Exporting #{scope.count} orders"

    scope.find_in_batches do |batch|
      batch.each do |order|
        order.notify_mail_chimp
        print '.'
      end
    end

    puts nil, 'done'
  end
end
