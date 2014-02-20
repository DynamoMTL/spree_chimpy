namespace :spree_chimpy do
  namespace :merge_vars do
    desc 'sync merge vars with mail chimp'
    task :sync => :environment do
      Spree::Chimpy.sync_merge_vars
      puts 'done'
    end
  end

  namespace :orders do
    desc 'sync all orders with mail chimp'
    task sync: :environment do
      scope = Spree::Order.complete

      puts "Exporting #{scope.count} orders"

      scope.find_in_batches do |batch|
        print '.'
        batch.each do |order|
          begin
            order.notify_mail_chimp
          rescue => exception
            puts exception
          end
        end
      end

      puts 'done.'
    end
  end

  namespace :users do
    desc 'Update subscribed status on Spree user class'
    task update_subscribed_status: :environment do
      puts "Updating all users from the subscribed list in Mailchimp"
      gibbon_export_api = Gibbon::Export.new(Spree::Chimpy::Config.key)
      list = gibbon_export_api.list({ id: Spree::Chimpy.list.list_id })
      header = list.shift
      source_index = header.split(',').index("\"Source\"")
      users_hash = list.map do |row|
        row_parts = row.split(',')
        source_part = row_parts[source_index]
        source = /\"(.+)\"/.match(source_part)
        source = source[1] if source
        email_part = row_parts[0]

        {
          email:  /\"(.+)\"/.match(email_part)[1],
          source: source
        }
      end

      users = Spree::User.where.not(subscribed: true)
      puts "Updating #{users.count} users. This will take a while..."
      users.find_each do |user|
        users_hash.each do |hash|
          if hash[:email] == user.email
            user.update_column(:subscribed, true)
            action = Spree::Chimpy::Action.where(email: user.email, action: :subscribe).last
            action.update_column(:source, hash[:source])
            puts "\nupdated #{user.id}"
          end
          print '.'
        end
      end
      
      puts "done."
    end

    desc 'Update merge vars on Mailchimp'
    task update_mailchimp_subscribers_info: :environment do
      puts "Updating Mailchimp data from Spree."
            
      users = Spree::User.where(subscribed: true)
      user_count = users.count
      puts "Updating #{user_count} users. This will take a while..."
      Spree::Chimpy.batch_subscribe(users)
      
      puts "done."
    end

    desc 'segment all subscribed users'
    task segment: :environment do
      if Spree::Chimpy.segment_exists?
        emails = Spree.user_class.where(subscribed: true).pluck(:email)
        emails = emails.map {|email| {email: email} }
        puts "Segmenting all subscribed users"
        response = Spree::Chimpy.list.segment(emails)
        response["errors"].try :each do |error|
          puts "Error #{error["code"]} with email: #{error["email"]} \n msg: #{error["msg"]}"
        end
        puts "segmented #{response['success_count'] || 0} out of #{emails.size}"
        puts "done."
      end
    end
  end
end
