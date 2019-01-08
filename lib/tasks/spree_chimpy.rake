namespace :spree_chimpy do
  namespace :merge_vars do
    desc 'sync merge vars with mail chimp'
    task :sync do
      Spree::Chimpy.sync_merge_vars
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
            if defined?(::Delayed::Job)
              raise exception
            else
              puts exception
            end
          end
        end
      end

      puts nil, 'done'
    end
  end

  namespace :users do
    desc 'segment all subscribed users'
    task segment: :environment do
      if Spree::Chimpy.segment_exists?
        emails = Spree.user_class.where(subscribed: true).pluck(:email)
        puts "Segmenting all subscribed users"
        response = Spree::Chimpy.list.segment(emails)
        response["errors"].try :each do |error|
          puts "Error #{error["code"]} with email: #{error["email"]} \n msg: #{error["msg"]}"
        end
        puts "segmented #{response["success"] || 0} out of #{emails.size}"
        puts "done"
      end
    end

    desc "sync all users from mailchimp"
    task sync_from_mailchimp: :environment do
      puts "Syncing users with data from Mailchimp"

      list = Spree::Chimpy.list

      emails_and_statuses = emails_and_statuses_for_list list

      puts "Found #{emails_and_statuses.count} members to update."

      grouped_emails = emails_and_statuses.group_by { |m| m["status"] }

      {
        "subscribed" => true,
        "unsubscribed" => false,
      }.each do |status, subscribed_db_value|
        emails_to_update = grouped_emails[status].map { |m| m["email_address"] }
        puts "Setting #{emails_to_update.count} emails to #{status}"
        Spree.user_class.where(email: emails_to_update).
          update_all(subscribed: subscribed_db_value)
      end
    end
  end

  # Iterate over list members, return a list of hashes with member information.
  # returns: [
  #   {"email_address" => "xxx@example.com", "status" => "subscribed"},
  #   ..., ...,
  # ]
  def emails_and_statuses_for_list(list)
    fields = %w(email_address members.status total_items)
    # YMMV, but given we are fetching a small number of fields, this is likely
    # safe.
    chunk_size = 5_000

    members = []
    total_items = nil
    list_params = { params: {
      fields: fields.join(","),
      count: chunk_size,
      offset: 0,
    } }

    # make the first request, and continue to iterate until we have all
    while total_items.nil? || members.count < total_items
      # useful if you want to debug the pagination
      # pp total_items, list_params

      # safety check!
      if total_items.present? && list_params[:params][:offset] > total_items
        fail "Fencepost error, unable to fetch all members.  This may be due "\
          "to changes in list size while iterating over it.  Please try "\
          "again at a less busy time."
      end
      # execute the query
      response = list.api_list_call.members.retrieve list_params
      # capture the results of this chunk
      members += response["members"]

      # update pagination tracking
      if total_items.nil?
        total_items = response["total_items"]
      elsif total_items != response["total_items"]
        warn "Total items shifted during pagination.  To ensure compelte data "\
          "you may want to re-run the script."
      end

      # update query parameters for next chunk
      list_params[:params][:offset] += chunk_size
    end

    members
  end
end
