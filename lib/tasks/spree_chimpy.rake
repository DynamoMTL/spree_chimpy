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
      header = JSON.load(header)
      source_index = header.index("Sign-Up Source") || header.index("Source")

      puts "#{list.count} members in the mailing list. This will take a while..."
      list.each do |row|
        json_row = JSON.load(row)
        source = json_row[source_index]
        email = json_row[0]
        user = Spree::User.find_or_create_unenrolled(email)
        user.update_column(:subscribed, true)

        action = Spree::Chimpy::Action.where(email: user.email, action: :subscribe).last
        if action
          action.update_column(:source, source) if source
        else
          Spree::Chimpy::Action.create(email: user.email, action: :subscribe, source: source)
        end
        print '.'
      end

      
      puts "done."
    end

    desc 'Update merge vars on Mailchimp'
    task update_mailchimp_subscribers_info: :environment do
      puts "Updating Mailchimp data from Spree."
      puts "Updating all users. This will take a while..."
      Spree::User.where(subscribed: true).find_in_batches do |group|
        email_batch = []
        group.each do |user| 
          email_batch << {
            email: {email: user.email},
            merge_vars: merge_vars(user)
          }
        end
        Spree::Chimpy.handle_event('batch_subscribe', {object: email_batch})
        print '.'
      end      
      puts "done."
    end


    desc 'segment all subscribed users'
    task segment: :environment do
      if Spree::Chimpy.segment_exists?
        emails = Spree.user_class.where(subscribed: true, enrolled: true).pluck(:email)
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
