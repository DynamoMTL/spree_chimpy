module Mailchimp


    class Folders
        attr_accessor :master

        def initialize(master)
            @master = master
        end

        # Add a new folder to file campaigns, autoresponders, or templates in
        # @param [String] name a unique name for a folder (max 100 bytes)
        # @param [String] type the type of folder to create - one of "campaign", "autoresponder", or "template".
        # @return [Hash] with a single value:
        #     - [Int] folder_id the folder_id of the newly created folder.
        def add(name, type)
            _params = {:name => name, :type => type}
            return @master.call 'folders/add', _params
        end

        # Delete a campaign, autoresponder, or template folder. Note that this will simply make whatever was in the folder appear unfiled, no other data is removed
        # @param [Int] fid the folder id to delete - retrieve from folders/list()
        # @param [String] type the type of folder to delete - either "campaign", "autoresponder", or "template"
        # @return [Hash] with a single entry:
        #     - [Bool] complete whether the call worked. reallistically this will always be true as errors will be thrown otherwise.
        def del(fid, type)
            _params = {:fid => fid, :type => type}
            return @master.call 'folders/del', _params
        end

        # List all the folders of a certain type
        # @param [String] type the type of folders to return "campaign", "autoresponder", or "template"
        # @return [Array] structs for each folder, including:
        #     - [Int] folder_id Folder Id for the given folder, this can be used in the campaigns/list() function to filter on.
        #     - [String] name Name of the given folder
        #     - [String] date_created The date/time the folder was created
        #     - [String] type The type of the folders being returned, just to make sure you know.
        #     - [Int] cnt number of items in the folder.
        def list(type)
            _params = {:type => type}
            return @master.call 'folders/list', _params
        end

        # Update the name of a folder for campaigns, autoresponders, or templates
        # @param [Int] fid the folder id to update - retrieve from folders/list()
        # @param [String] name a new, unique name for the folder (max 100 bytes)
        # @param [String] type the type of folder to update - one of "campaign", "autoresponder", or "template".
        # @return [Hash] with a single entry:
        #     - [Bool] complete whether the call worked. reallistically this will always be true as errors will be thrown otherwise.
        def update(fid, name, type)
            _params = {:fid => fid, :name => name, :type => type}
            return @master.call 'folders/update', _params
        end

    end
    class Templates
        attr_accessor :master

        def initialize(master)
            @master = master
        end

        # Create a new user template, <strong>NOT</strong> campaign content. These templates can then be applied while creating campaigns.
        # @param [String] name the name for the template - names must be unique and a max of 50 bytes
        # @param [String] html a string specifying the entire template to be created. This is <strong>NOT</strong> campaign content. They are intended to utilize our <a href="http://www.mailchimp.com/resources/email-template-language/" target="_blank">template language</a>.
        # @param [Int] folder_id the folder to put this template in.
        # @return [Hash] with a single element:
        #     - [Int] template_id the new template id, otherwise an error is thrown.
        def add(name, html, folder_id=nil)
            _params = {:name => name, :html => html, :folder_id => folder_id}
            return @master.call 'templates/add', _params
        end

        # Delete (deactivate) a user template
        # @param [Int] template_id the id of the user template to delete
        # @return [Hash] with a single entry:
        #     - [Bool] complete whether the call worked. reallistically this will always be true as errors will be thrown otherwise.
        def del(template_id)
            _params = {:template_id => template_id}
            return @master.call 'templates/del', _params
        end

        # Pull details for a specific template to help support editing
        # @param [Int] template_id the template id - get from templates/list()
        # @param [String] type optional the template type to load - one of 'user', 'gallery', 'base', defaults to user.
        # @return [Hash] info to be used when editing
        #     - [Hash] default_content the default content broken down into the named editable sections for the template - dependant upon template, so not documented
        #     - [Hash] sections the valid editable section names - dependant upon template, so not documented
        #     - [String] source the full source of the template as if you exported it via our template editor
        #     - [String] preview similar to the source, but the rendered version of the source from our popup preview
        def info(template_id, type='user')
            _params = {:template_id => template_id, :type => type}
            return @master.call 'templates/info', _params
        end

        # Retrieve various templates available in the system, allowing some thing similar to our template gallery to be created.
        # @param [Hash] types optional the types of templates to return
        #     - [Boolean] user Custom templates for this user account. Defaults to true.
        #     - [Boolean] gallery Templates from our Gallery. Note that some templates that require extra configuration are withheld. (eg, the Etsy template). Defaults to false.
        #     - [Boolean] base Our "start from scratch" extremely basic templates. Defaults to false.
        # @param [Hash] filters optional options to control how inactive templates are returned, if at all
        #     - [String] category optional for Gallery templates only, limit to a specific template category
        #     - [String] folder_id user templates, limit to this folder_id
        #     - [Boolean] include_inactive user templates are not deleted, only set inactive. defaults to false.
        #     - [Boolean] inactive_only only include inactive user templates. defaults to false.
        # @return [Hash] for each type
        #     - [Array] user matching user templates, if requested.
        #         - [Int] id Id of the template
        #         - [String] name Name of the template
        #         - [String] layout General description of the layout of the template
        #         - [String] category The category for the template, if there is one.
        #         - [String] preview_image If we've generated it, the url of the preview image for the template. We do out best to keep these up to date, but Preview image urls are not guaranteed to be available
        #         - [String] date_created The date/time the template was created
        #         - [Boolean] active whether or not the template is active and available for use.
        #         - [Boolean] edit_source Whether or not you are able to edit the source of a template.
        #         - [Boolean] folder_id if it's in one, the folder id
        #     - [Array] gallery matching gallery templates, if requested.
        #         - [Int] id Id of the template
        #         - [String] name Name of the template
        #         - [String] layout General description of the layout of the template
        #         - [String] category The category for the template, if there is one.
        #         - [String] preview_image If we've generated it, the url of the preview image for the template. We do out best to keep these up to date, but Preview image urls are not guaranteed to be available
        #         - [String] date_created The date/time the template was created
        #         - [Boolean] active whether or not the template is active and available for use.
        #         - [Boolean] edit_source Whether or not you are able to edit the source of a template.
        #     - [Array] base matching base templates, if requested.
        #         - [Int] id Id of the template
        #         - [String] name Name of the template
        #         - [String] layout General description of the layout of the template
        #         - [String] category The category for the template, if there is one.
        #         - [String] preview_image If we've generated it, the url of the preview image for the template. We do out best to keep these up to date, but Preview image urls are not guaranteed to be available
        #         - [Boolean] active whether or not the template is active and available for use.
        #         - [String] date_created The date/time the template was created
        #         - [Boolean] edit_source Whether or not you are able to edit the source of a template.
        def list(types=[], filters=[])
            _params = {:types => types, :filters => filters}
            return @master.call 'templates/list', _params
        end

        # Undelete (reactivate) a user template
        # @param [Int] template_id the id of the user template to reactivate
        # @return [Hash] with a single entry:
        #     - [Bool] complete whether the call worked. reallistically this will always be true as errors will be thrown otherwise.
        def undel(template_id)
            _params = {:template_id => template_id}
            return @master.call 'templates/undel', _params
        end

        # Replace the content of a user template, <strong>NOT</strong> campaign content.
        # @param [Int] template_id the id of the user template to update
        # @param [Hash] values the values to updates - while both are optional, at least one should be provided. Both can be updated at the same time.
        #     - [String] name the name for the template - names must be unique and a max of 50 bytes
        #     - [String] html a string specifying the entire template to be created. This is <strong>NOT</strong> campaign content. They are intended to utilize our <a href="http://www.mailchimp.com/resources/email-template-language/" target="_blank">template language</a>.
        #     - [Int] folder_id the folder to put this template in - 0 or a blank values will remove it from a folder.
        # @return [Hash] with a single entry:
        #     - [Bool] complete whether the call worked. reallistically this will always be true as errors will be thrown otherwise.
        def update(template_id, values)
            _params = {:template_id => template_id, :values => values}
            return @master.call 'templates/update', _params
        end

    end
    class Users
        attr_accessor :master

        def initialize(master)
            @master = master
        end

        # Invite a user to your account
        # @param [String] email A valid email address to send the invitation to
        # @param [String] role the role to assign to the user - one of viewer, author, manager, admin. defaults to viewer. More details <a href="http://kb.mailchimp.com/article/can-we-have-multiple-users-on-our-account-with-limited-access" target="_blank">here</a>
        # @param [String] msg an optional message to include. Plain text any HTML tags will be stripped.
        # @return [Hash] the method completion status
        #     - [String] status The status (success) of the call if it completed. Otherwise an error is thrown.
        def invite(email, role='viewer', msg='')
            _params = {:email => email, :role => role, :msg => msg}
            return @master.call 'users/invite', _params
        end

        # Resend an invite a user to your account. Note, if the same address has been invited multiple times, this will simpy re-send the most recent invite
        # @param [String] email A valid email address to resend an invitation to
        # @return [Hash] the method completion status
        #     - [String] status The status (success) of the call if it completed. Otherwise an error is thrown.
        def invite_resend(email)
            _params = {:email => email}
            return @master.call 'users/invite-resend', _params
        end

        # Revoke an invitation sent to a user to your account. Note, if the same address has been invited multiple times, this will simpy revoke the most recent invite
        # @param [String] email A valid email address to send the invitation to
        # @return [Hash] the method completion status
        #     - [String] status The status (success) of the call if it completed. Otherwise an error is thrown.
        def invite_revoke(email)
            _params = {:email => email}
            return @master.call 'users/invite-revoke', _params
        end

        # Retrieve the list of pending users invitations have been sent for.
        # @return [Array] structs for each invitation, including:
        #     - [String] email the email address the invitation was sent to
        #     - [String] role the role that will be assigned if they accept
        #     - [String] sent_at the time the invitation was sent. this will change if it's resent.
        #     - [String] expiration the expiration time for the invitation. this will change if it's resent.
        #     - [String] msg the welcome message included with the invitation
        def invites()
            _params = {}
            return @master.call 'users/invites', _params
        end

        # Revoke access for a specified login
        # @param [String] username The username of the login to revoke access of
        # @return [Hash] the method completion status
        #     - [String] status The status (success) of the call if it completed. Otherwise an error is thrown.
        def login_revoke(username)
            _params = {:username => username}
            return @master.call 'users/login-revoke', _params
        end

        # Retrieve the list of active logins.
        # @return [Array] structs for each user, including:
        #     - [Int] id the login id for this login
        #     - [String] username the username used to log in
        #     - [String] name a display name for the account - empty first/last names will return the username
        #     - [String] email the email tied to the account used for passwords resets and the ilk
        #     - [String] role the role assigned to the account
        #     - [String] avatar if available, the url for the login's avatar
        def logins()
            _params = {}
            return @master.call 'users/logins', _params
        end

        # Retrieve the profile for the login owning the provided API Key
        # @return [Hash] the current user's details, including:
        #     - [Int] id the login id for this login
        #     - [String] username the username used to log in
        #     - [String] name a display name for the account - empty first/last names will return the username
        #     - [String] email the email tied to the account used for passwords resets and the ilk
        #     - [String] role the role assigned to the account
        #     - [String] avatar if available, the url for the login's avatar
        def profile()
            _params = {}
            return @master.call 'users/profile', _params
        end

    end
    class Helper
        attr_accessor :master

        def initialize(master)
            @master = master
        end

        # Retrieve lots of account information including payments made, plan info, some account stats, installed modules, contact info, and more. No private information like Credit Card numbers is available.
        # @param [Array] exclude defaults to nothing for backwards compatibility. Allows controlling which extra arrays are returned since they can slow down calls. Valid keys are "modules", "orders", "rewards-credits", "rewards-inspections", "rewards-referrals", "rewards-applied", "integrations". Hint: "rewards-referrals" is typically the culprit. To avoid confusion, if data is excluded, the corresponding key <strong>will not be returned at all</strong>.
        # @return [Hash] containing the details for the account tied to this API Key
        #     - [String] username The Account username
        #     - [String] user_id The Account user unique id (for building some links)
        #     - [Bool] is_trial Whether the Account is in Trial mode (can only send campaigns to less than 100 emails)
        #     - [Bool] is_approved Whether the Account has been approved for purchases
        #     - [Bool] has_activated Whether the Account has been activated
        #     - [String] timezone The timezone for the Account - default is "US/Eastern"
        #     - [String] plan_type Plan Type - "monthly", "payasyougo", or "free"
        #     - [Int] plan_low <em>only for Monthly plans</em> - the lower tier for list size
        #     - [Int] plan_high <em>only for Monthly plans</em> - the upper tier for list size
        #     - [String] plan_start_date <em>only for Monthly plans</em> - the start date for a monthly plan
        #     - [Int] emails_left <em>only for Free and Pay-as-you-go plans</em> emails credits left for the account
        #     - [Bool] pending_monthly Whether the account is finishing Pay As You Go credits before switching to a Monthly plan
        #     - [String] first_payment date of first payment
        #     - [String] last_payment date of most recent payment
        #     - [Int] times_logged_in total number of times the account has been logged into via the web
        #     - [String] last_login date/time of last login via the web
        #     - [String] affiliate_link Monkey Rewards link for our Affiliate program
        #     - [String] industry the user's selected industry
        #     - [Hash] contact Contact details for the account
        #         - [String] fname First Name
        #         - [String] lname Last Name
        #         - [String] email Email Address
        #         - [String] company Company Name
        #         - [String] address1 Address Line 1
        #         - [String] address2 Address Line 2
        #         - [String] city City
        #         - [String] state State or Province
        #         - [String] zip Zip or Postal Code
        #         - [String] country Country name
        #         - [String] url Website URL
        #         - [String] phone Phone number
        #         - [String] fax Fax number
        #     - [Array] modules a struct for each addon module installed in the account
        #         - [String] id An internal module id
        #         - [String] name The module name
        #         - [String] added The date the module was added
        #         - [Hash] data Any extra data associated with this module as key=>value pairs
        #     - [Array] orders a struct for each order for the account
        #         - [Int] order_id The order id
        #         - [String] type The order type - either "monthly" or "credits"
        #         - [Double] amount The order amount
        #         - [String] date The order date
        #         - [Double] credits_used The total credits used
        #     - [Hash] rewards Rewards details for the account including credits & inspections earned, number of referrals, referral details, and rewards used
        #         - [Int] referrals_this_month the total number of referrals this month
        #         - [String] notify_on whether or not we notify the user when rewards are earned
        #         - [String] notify_email the email address address used for rewards notifications
        #         - [Hash] credits Email credits earned:
        #             - [Int] this_month credits earned this month
        #             - [Int] total_earned credits earned all time
        #             - [Int] remaining credits remaining
        #         - [Hash] inspections Inbox Inspections earned:
        #             - [Int] this_month credits earned this month
        #             - [Int] total_earned credits earned all time
        #             - [Int] remaining credits remaining
        #         - [Array] referrals a struct for each referral, including:
        #             - [String] name the name of the account
        #             - [String] email the email address associated with the account
        #             - [String] signup_date the signup date for the account
        #             - [String] type the source for the referral
        #         - [Array] applied a struct for each applied rewards, including:
        #             - [Int] value the number of credits user
        #             - [String] date the date applied
        #             - [Int] order_id the order number credits were applied to
        #             - [String] order_desc the order description
        #     - [Array] integrations a struct for each connected integrations that can be used with campaigns, including:
        #         - [Int] id an internal id for the integration
        #         - [String] name the integration name
        #         - [String] list_id either "_any_" when globally accessible or the list id it's valid for use against
        #         - [String] user_id if applicable, the user id for the integrated system
        #         - [String] account if applicable, the user/account name for the integrated system
        #         - [Array] profiles For Facebook, users/page that can be posted to.
        #             - [String] id the user or page id
        #             - [String] name the user or page name
        #             - [Bool] is_page whether this is a user or a page
        def account_details(exclude=[])
            _params = {:exclude => exclude}
            return @master.call 'helper/account-details', _params
        end

        # Retrieve minimal data for all Campaigns a member was sent
        # @param [Hash] email a struct with one fo the following keys - failing to provide anything will produce an error relating to the email address
        #     - [String] email an email address
        #     - [String] euid the unique id for an email address (not list related) - the email "id" returned from listMemberInfo, Webhooks, Campaigns, etc.
        #     - [String] leid the list email id (previously called web_id) for a list-member-info type call. this doesn't change when the email address changes
        # @param [Hash] options optional extra options to modify the returned data.
        #     - [String] list_id optional A list_id to limit the campaigns to
        # @return [Array] an array of structs containing campaign data for each matching campaign (ordered by send time ascending), including:
        #     - [String] id the campaign unique id
        #     - [String] title the campaign's title
        #     - [String] subject the campaign's subject
        #     - [String] send_time the time the campaign was sent
        #     - [String] type the campaign type
        def campaigns_for_email(email, options=nil)
            _params = {:email => email, :options => options}
            return @master.call 'helper/campaigns-for-email', _params
        end

        # Return the current Chimp Chatter messages for an account.
        # @return [Array] An array of structs containing data for each chatter message
        #     - [String] message The chatter message
        #     - [String] type The type of the message - one of lists:new-subscriber, lists:unsubscribes, lists:profile-updates, campaigns:facebook-likes, campaigns:facebook-comments, campaigns:forward-to-friend, lists:imports, or campaigns:inbox-inspections
        #     - [String] url a url into the web app that the message could link to, if applicable
        #     - [String] list_id the list_id a message relates to, if applicable. Deleted lists will return -DELETED-
        #     - [String] campaign_id the list_id a message relates to, if applicable. Deleted campaigns will return -DELETED-
        #     - [String] update_time The date/time the message was last updated
        def chimp_chatter()
            _params = {}
            return @master.call 'helper/chimp-chatter', _params
        end

        # Have HTML content auto-converted to a text-only format. You can send: plain HTML, an existing Campaign Id, or an existing Template Id. Note that this will <strong>not</strong> save anything to or update any of your lists, campaigns, or templates. It's also not just Lynx and is very fine tuned for our template layouts - your mileage may vary.
        # @param [String] type The type of content to parse. Must be one of: "html", "url", "cid" (Campaign Id), "user_template_id", "base_template_id", "gallery_template_id"
        # @param [Hash] content The content to use. The key names should be the same as type and while listed as optional, may cause errors if the content is obviously required (ie, html)
        #     - [String] html optional a single string value,
        #     - [String] cid a valid Campaign Id
        #     - [String] user_template_id the id of a user template
        #     - [String] base_template_id the id of a built in base/basic template
        #     - [String] gallery_template_id the id of a built in gallery template
        #     - [String] url a valid & public URL to pull html content from
        # @return [Hash] the content pass in converted to text.
        #     - [String] text the converted html
        def generate_text(type, content)
            _params = {:type => type, :content => content}
            return @master.call 'helper/generate-text', _params
        end

        # Send your HTML content to have the CSS inlined and optionally remove the original styles.
        # @param [String] html Your HTML content
        # @param [Bool] strip_css optional Whether you want the CSS &lt;style&gt; tags stripped from the returned document. Defaults to false.
        # @return [Hash] with a "html" key
        #     - [String] html Your HTML content with all CSS inlined, just like if we sent it.
        def inline_css(html, strip_css=false)
            _params = {:html => html, :strip_css => strip_css}
            return @master.call 'helper/inline-css', _params
        end

        # Retrieve minimal List data for all lists a member is subscribed to.
        # @param [Hash] email a struct with one fo the following keys - failing to provide anything will produce an error relating to the email address
        #     - [String] email an email address
        #     - [String] euid the unique id for an email address (not list related) - the email "id" returned from listMemberInfo, Webhooks, Campaigns, etc.
        #     - [String] leid the list email id (previously called web_id) for a list-member-info type call. this doesn't change when the email address changes
        # @return [Array] An array of structs with info on the  list_id the member is subscribed to.
        #     - [String] id the list unique id
        #     - [Web_id] the id referenced in web interface urls
        #     - [Name] the list name
        def lists_for_email(email)
            _params = {:email => email}
            return @master.call 'helper/lists-for-email', _params
        end

        # "Ping" the MailChimp API - a simple method you can call that will return a constant value as long as everything is good. Note than unlike most all of our methods, we don't throw an Exception if we are having issues. You will simply receive a different string back that will explain our view on what is going on.
        # @return [Hash] a with a "msg" key
        #     - [String] msg containing "Everything's Chimpy!" if everything is chimpy, otherwise returns an error message
        def ping()
            _params = {}
            return @master.call 'helper/ping', _params
        end

        # Search all campaigns for the specified query terms
        # @param [String] query terms to search on
        # @param [Int] offset optional the paging offset to use if more than 100 records match
        # @param [String] snip_start optional by default clear text is returned. To have the match highlighted with something (like a strong HTML tag), <strong>both</strong> this and "snip_end" must be passed. You're on your own to not break the tags - 25 character max.
        # @param [String] snip_end optional see "snip_start" above.
        # @return [Hash] containing the total matches and current results
        #     - [Int] total total campaigns matching
        #     - [Array] results matching campaigns and snippets
        #     - [String] snippet the matching snippet for the campaign
        #     - [Hash] campaign the matching campaign's details - will return same data as single campaign from campaigns/list()
        #     - [Hash] summary if available, the matching campaign's report/summary data, other wise empty
        def search_campaigns(query, offset=0, snip_start=nil, snip_end=nil)
            _params = {:query => query, :offset => offset, :snip_start => snip_start, :snip_end => snip_end}
            return @master.call 'helper/search-campaigns', _params
        end

        # Search account wide or on a specific list using the specified query terms
        # @param [String] query terms to search on, <a href="http://kb.mailchimp.com/article/i-cant-find-a-recipient-on-my-list" target="_blank">just like you do in the app</a>
        # @param [String] id optional the list id to limit the search to. Get by calling lists/list()
        # @param [Int] offset optional the paging offset to use if more than 100 records match
        # @return [Hash] An array of both exact matches and partial matches over a full search
        #     - [Hash] exact_matches containing the total matches and current results
        #     - [Int] total total members matching
        #     - [Array] members each entry will be struct matching the data format for a single member as returned by lists/member-info()
        #     - [Hash] full_search containing the total matches and current results
        #     - [Int] total total members matching
        #     - [Array] members each entry will be struct matching  the data format for a single member as returned by lists/member-info()
        def search_members(query, id=nil, offset=0)
            _params = {:query => query, :id => id, :offset => offset}
            return @master.call 'helper/search-members', _params
        end

        # Retrieve all domain verification records for an account
        # @return [Array] structs for each domain verification has been attempted for
        #     - [String] domain the verified domain
        #     - [String] status the status of the verification - either "verified" or "pending"
        #     - [String] email the email address used for verification - "pre-existing" if we automatically backfilled it at some point
        def verified_domains()
            _params = {}
            return @master.call 'helper/verified-domains', _params
        end

    end
    class Mobile
        attr_accessor :master

        def initialize(master)
            @master = master
        end

    end
    class Ecomm
        attr_accessor :master

        def initialize(master)
            @master = master
        end

        # Import Ecommerce Order Information to be used for Segmentation. This will generally be used by ecommerce package plugins <a href="http://connect.mailchimp.com/category/ecommerce" target="_blank">provided by us or by 3rd part system developers</a>.
        # @param [Hash] order information pertaining to the order that has completed. Use the following keys:
        #     - [String] id the Order Id
        #     - [String] campaign_id optional the Campaign Id to track this order against (see the "mc_cid" query string variable a campaign passes)
        #     - [String] email_id optional (kind of) the Email Id of the subscriber we should attach this order to (see the "mc_eid" query string variable a campaign passes) - required if campaign_id is passed, otherwise either this or <strong>email</strong> is required. If both are provided, email_id takes precedence
        #     - [String] email optional (kind of) the Email Address we should attach this order to - either this or <strong>email_id</strong> is required. If both are provided, email_id takes precedence
        #     - [Double] total The Order Total (ie, the full amount the customer ends up paying)
        #     - [String] order_date optional the date of the order - if this is not provided, we will default the date to now. Should be in the format of 2012-12-30
        #     - [Double] shipping optional the total paid for Shipping Fees
        #     - [Double] tax optional the total tax paid
        #     - [String] store_id a unique id for the store sending the order in (32 bytes max)
        #     - [String] store_name optional a "nice" name for the store - typically the base web address (ie, "store.mailchimp.com"). We will automatically update this if it changes (based on store_id)
        #     - [Array] items structs for each individual line item including:
        #         - [Int] line_num optional the line number of the item on the order. We will generate these if they are not passed
        #         - [Int] product_id the store's internal Id for the product. Lines that do no contain this will be skipped
        #         - [String] sku optional the store's internal SKU for the product. (max 30 bytes)
        #         - [String] product_name the product name for the product_id associated with this item. We will auto update these as they change (based on product_id)
        #         - [Int] category_id the store's internal Id for the (main) category associated with this product. Our testing has found this to be a "best guess" scenario
        #         - [String] category_name the category name for the category_id this product is in. Our testing has found this to be a "best guess" scenario. Our plugins walk the category heirarchy up and send "Root - SubCat1 - SubCat4", etc.
        #         - [Double] qty optional the quantity of the item ordered - defaults to 1
        #         - [Double] cost optional the cost of a single item (ie, not the extended cost of the line) - defaults to 0
        # @return [Hash] with a single entry:
        #     - [Bool] complete whether the call worked. reallistically this will always be true as errors will be thrown otherwise.
        def order_add(order)
            _params = {:order => order}
            return @master.call 'ecomm/order-add', _params
        end

        # Delete Ecommerce Order Information used for segmentation. This will generally be used by ecommerce package plugins <a href="/plugins/ecomm360.phtml">that we provide</a> or by 3rd part system developers.
        # @param [String] store_id the store id the order belongs to
        # @param [String] order_id the order id (generated by the store) to delete
        # @return [Hash] with a single entry:
        #     - [Bool] complete whether the call worked. reallistically this will always be true as errors will be thrown otherwise.
        def order_del(store_id, order_id)
            _params = {:store_id => store_id, :order_id => order_id}
            return @master.call 'ecomm/order-del', _params
        end

        # Retrieve the Ecommerce Orders for an account
        # @param [String] cid if set, limit the returned orders to a particular campaign
        # @param [Int] start optional for large data sets, the page number to start at - defaults to 1st page of data  (page 0)
        # @param [Int] limit optional for large data sets, the number of results to return - defaults to 100, upper limit set at 500
        # @param [String] since optional pull only messages since this time - 24 hour format in <strong>GMT</strong>, eg "2013-12-30 20:30:00"
        # @return [Hash] the total matching orders and the specific orders for the requested page
        #     - [Int] total the total matching orders
        #     - [Array] data structs for each order being returned
        #         - [String] store_id the store id generated by the plugin used to uniquely identify a store
        #         - [String] store_name the store name collected by the plugin - often the domain name
        #         - [String] order_id the internal order id the store tracked this order by
        #         - [String] email the email address that received this campaign and is associated with this order
        #         - [Double] order_total the order total
        #         - [Double] tax_total the total tax for the order (if collected)
        #         - [Double] ship_total the shipping total for the order (if collected)
        #         - [String] order_date the date the order was tracked - from the store if possible, otherwise the GMT time we received it
        #         - [Array] items structs for each line item on this order.:
        #             - [Int] line_num the line number
        #             - [Int] product_id the product id
        #             - [String] product_name the product name
        #             - [String] product_sku the sku for the product
        #             - [Int] product_category_id the category id for the product
        #             - [String] product_category_name the category name for the product
        #             - [Int] qty the quantity ordered
        #             - [Double] cost the cost of the item
        def orders(cid=nil, start=0, limit=100, since=nil)
            _params = {:cid => cid, :start => start, :limit => limit, :since => since}
            return @master.call 'ecomm/orders', _params
        end

    end
    class Neapolitan
        attr_accessor :master

        def initialize(master)
            @master = master
        end

    end
    class Lists
        attr_accessor :master

        def initialize(master)
            @master = master
        end

        # Get all email addresses that complained about a campaign sent to a list
        # @param [String] id the list id to pull abuse reports for (can be gathered using lists/list())
        # @param [Int] start optional for large data sets, the page number to start at - defaults to 1st page of data  (page 0)
        # @param [Int] limit optional for large data sets, the number of results to return - defaults to 500, upper limit set at 1000
        # @param [String] since optional pull only messages since this time - 24 hour format in <strong>GMT</strong>, eg "2013-12-30 20:30:00"
        # @return [Hash] the total of all reports and the specific reports reports this page
        #     - [Int] total the total number of matching abuse reports
        #     - [Array] data structs for the actual data for each reports, including:
        #         - [String] date date+time the abuse report was received and processed
        #         - [String] email the email address that reported abuse
        #         - [String] campaign_id the unique id for the campaign that report was made against
        #         - [String] type an internal type generally specifying the originating mail provider - may not be useful outside of filling report views
        def abuse_reports(id, start=0, limit=500, since=nil)
            _params = {:id => id, :start => start, :limit => limit, :since => since}
            return @master.call 'lists/abuse-reports', _params
        end

        # Access up to the previous 180 days of daily detailed aggregated activity stats for a given list. Does not include AutoResponder activity.
        # @param [String] id the list id to connect to. Get by calling lists/list()
        # @return [Array] of structs containing daily values, each containing:
        def activity(id)
            _params = {:id => id}
            return @master.call 'lists/activity', _params
        end

        # Subscribe a batch of email addresses to a list at once. If you are using a serialized version of the API, we strongly suggest that you only run this method as a POST request, and <em>not</em> a GET request. Maximum batch sizes vary based on the amount of data in each record, though you should cap them at 5k - 10k records, depending on your experience. These calls are also long, so be sure you increase your timeout values.
        # @param [String] id the list id to connect to. Get by calling lists/list()
        # @param [Array] batch an array of structs for each address using the following keys:
        #     - [Hash] email a struct with one of the following keys - failing to provide anything will produce an error relating to the email address. Provide multiples and we'll use the first we see in this same order.
        #         - [String] email an email address
        #         - [String] euid the unique id for an email address (not list related) - the email "id" returned from listMemberInfo, Webhooks, Campaigns, etc.
        #         - [String] leid the list email id (previously called web_id) for a list-member-info type call. this doesn't change when the email address changes
        #     - [String] email_type for the email type option (html or text)
        #     - [Hash] merge_vars data for the various list specific and special merge vars documented in lists/subscribe
        # @param [Boolean] double_optin flag to control whether to send an opt-in confirmation email - defaults to true
        # @param [Boolean] update_existing flag to control whether to update members that are already subscribed to the list or to return an error, defaults to false (return error)
        # @param [Boolean] replace_interests flag to determine whether we replace the interest groups with the updated groups provided, or we add the provided groups to the member's interest groups (optional, defaults to true)
        # @return [Hash] struct of result counts and associated data
        #     - [Int] add_count Number of email addresses that were successfully added
        #     - [Array] adds array of structs for each add
        #         - [String] email the email address added
        #         - [String] euid the email unique id
        #         - [String] leid the list member's truly unique id
        #     - [Int] update_count Number of email addresses that were successfully updated
        #     - [Array] updates array of structs for each update
        #         - [String] email the email address added
        #         - [String] euid the email unique id
        #         - [String] leid the list member's truly unique id
        #     - [Int] error_count Number of email addresses that failed during addition/updating
        #     - [Array] errors array of error structs including:
        #         - [String] email whatever was passed in the batch record's email parameter
        #             - [String] email the email address added
        #             - [String] euid the email unique id
        #             - [String] leid the list member's truly unique id
        #         - [Int] code the error code
        #         - [String] error the full error message
        #         - [Hash] row the row from the batch that caused the error
        def batch_subscribe(id, batch, double_optin=true, update_existing=false, replace_interests=true)
            _params = {:id => id, :batch => batch, :double_optin => double_optin, :update_existing => update_existing, :replace_interests => replace_interests}
            return @master.call 'lists/batch-subscribe', _params
        end

        # Unsubscribe a batch of email addresses from a list
        # @param [String] id the list id to connect to. Get by calling lists/list()
        # @param [Array] batch array of structs to unsubscribe, each with one of the following keys - failing to provide anything will produce an error relating to the email address. Provide multiples and we'll use the first we see in this same order.
        #     - [String] email an email address
        #     - [String] euid the unique id for an email address (not list related) - the email "id" returned from listMemberInfo, Webhooks, Campaigns, etc.
        #     - [String] leid the list email id (previously called web_id) for a list-member-info type call. this doesn't change when the email address changes
        # @param [Boolean] delete_member flag to completely delete the member from your list instead of just unsubscribing, default to false
        # @param [Boolean] send_goodbye flag to send the goodbye email to the email addresses, defaults to true
        # @param [Boolean] send_notify flag to send the unsubscribe notification email to the address defined in the list email notification settings, defaults to false
        # @return [Array] Array of structs containing results and any errors that occurred
        #     - [Int] success_count Number of email addresses that were successfully removed
        #     - [Int] error_count Number of email addresses that failed during addition/updating
        #     - [Array] of structs contain error details including:
        #     - [Array] errors array of error structs including:
        #         - [String] email whatever was passed in the batch record's email parameter
        #             - [String] email the email address added
        #             - [String] euid the email unique id
        #             - [String] leid the list member's truly unique id
        #         - [Int] code the error code
        #         - [String] error the full error message
        def batch_unsubscribe(id, batch, delete_member=false, send_goodbye=true, send_notify=false)
            _params = {:id => id, :batch => batch, :delete_member => delete_member, :send_goodbye => send_goodbye, :send_notify => send_notify}
            return @master.call 'lists/batch-unsubscribe', _params
        end

        # Retrieve the clients that the list's subscribers have been tagged as being used based on user agents seen. Made possible by <a href="http://user-agent-string.info" target="_blank">user-agent-string.info</a>
        # @param [String] id the list id to connect to. Get by calling lists/list()
        # @return [Hash] the desktop and mobile user agents in use on the list
        #     - [Hash] desktop desktop user agents and percentages
        #         - [Double] penetration the percent of desktop clients in use
        #         - [Array] clients array of structs for each client including:
        #             - [String] client the common name for the client
        #             - [String] icon a url to an image representing this client
        #             - [String] percent percent of list using the client
        #             - [String] members total members using the client
        #     - [Hash] mobile mobile user agents and percentages
        #         - [Double] penetration the percent of mobile clients in use
        #         - [Array] clients array of structs for each client including:
        #             - [String] client the common name for the client
        #             - [String] icon a url to an image representing this client
        #             - [String] percent percent of list using the client
        #             - [String] members total members using the client
        def clients(id)
            _params = {:id => id}
            return @master.call 'lists/clients', _params
        end

        # Access the Growth History by Month in aggregate or for a given list.
        # @param [String] id optional - if provided, the list id to connect to. Get by calling lists/list(). Otherwise the aggregate for the account.
        # @return [Array] array of structs containing months and growth data
        #     - [String] month The Year and Month in question using YYYY-MM format
        #     - [Int] existing number of existing subscribers to start the month
        #     - [Int] imports number of subscribers imported during the month
        #     - [Int] optins number of subscribers who opted-in during the month
        def growth_history(id=nil)
            _params = {:id => id}
            return @master.call 'lists/growth-history', _params
        end

        # Get the list of interest groupings for a given list, including the label, form information, and included groups for each
        # @param [String] id the list id to connect to. Get by calling lists/list()
        # @param [Bool] counts optional whether or not to return subscriber counts for each group. defaults to false since that slows this call down a ton for large lists.
        # @return [Array] array of structs of the interest groupings for the list
        #     - [Int] id The id for the Grouping
        #     - [String] name Name for the Interest groups
        #     - [String] form_field Gives the type of interest group: checkbox,radio,select
        #     - [Array] groups Array structs of the grouping options (interest groups) including:
        #         - [String] bit the bit value - not really anything to be done with this
        #         - [String] name the name of the group
        #         - [String] display_order the display order of the group, if set
        #         - [Int] subscribers total number of subscribers who have this group if "counts" is true. otherwise empty
        def interest_groupings(id, counts=false)
            _params = {:id => id, :counts => counts}
            return @master.call 'lists/interest-groupings', _params
        end

        # Add a single Interest Group - if interest groups for the List are not yet enabled, adding the first group will automatically turn them on.
        # @param [String] id the list id to connect to. Get by calling lists/list()
        # @param [String] group_name the interest group to add - group names must be unique within a grouping
        # @param [Int] grouping_id optional The grouping to add the new group to - get using lists/interest-groupings() . If not supplied, the first grouping on the list is used.
        # @return [Hash] with a single entry:
        #     - [Bool] complete whether the call worked. reallistically this will always be true as errors will be thrown otherwise.
        def interest_group_add(id, group_name, grouping_id=nil)
            _params = {:id => id, :group_name => group_name, :grouping_id => grouping_id}
            return @master.call 'lists/interest-group-add', _params
        end

        # Delete a single Interest Group - if the last group for a list is deleted, this will also turn groups for the list off.
        # @param [String] id the list id to connect to. Get by calling lists/list()
        # @param [String] group_name the interest group to delete
        # @param [Int] grouping_id The grouping to delete the group from - get using lists/interest-groupings() . If not supplied, the first grouping on the list is used.
        # @return [Hash] with a single entry:
        #     - [Bool] complete whether the call worked. reallistically this will always be true as errors will be thrown otherwise.
        def interest_group_del(id, group_name, grouping_id=nil)
            _params = {:id => id, :group_name => group_name, :grouping_id => grouping_id}
            return @master.call 'lists/interest-group-del', _params
        end

        # Change the name of an Interest Group
        # @param [String] id the list id to connect to. Get by calling lists/list()
        # @param [String] old_name the interest group name to be changed
        # @param [String] new_name the new interest group name to be set
        # @param [Int] grouping_id optional The grouping to delete the group from - get using lists/interest-groupings() . If not supplied, the first grouping on the list is used.
        # @return [Hash] with a single entry:
        #     - [Bool] complete whether the call worked. reallistically this will always be true as errors will be thrown otherwise.
        def interest_group_update(id, old_name, new_name, grouping_id=nil)
            _params = {:id => id, :old_name => old_name, :new_name => new_name, :grouping_id => grouping_id}
            return @master.call 'lists/interest-group-update', _params
        end

        # Add a new Interest Grouping - if interest groups for the List are not yet enabled, adding the first grouping will automatically turn them on.
        # @param [String] id the list id to connect to. Get by calling lists/list()
        # @param [String] name the interest grouping to add - grouping names must be unique
        # @param [String] type The type of the grouping to add - one of "checkboxes", "hidden", "dropdown", "radio"
        # @param [Array] groups The lists of initial group names to be added - at least 1 is required and the names must be unique within a grouping. If the number takes you over the 60 group limit, an error will be thrown.
        # @return [Hash] with a single entry:
        #     - [Int] id the new grouping id if the request succeeds, otherwise an error will be thrown
        def interest_grouping_add(id, name, type, groups)
            _params = {:id => id, :name => name, :type => type, :groups => groups}
            return @master.call 'lists/interest-grouping-add', _params
        end

        # Delete an existing Interest Grouping - this will permanently delete all contained interest groups and will remove those selections from all list members
        # @param [Int] grouping_id the interest grouping id - get from lists/interest-groupings()
        # @return [Hash] with a single entry:
        #     - [Bool] complete whether the call worked. reallistically this will always be true as errors will be thrown otherwise.
        def interest_grouping_del(grouping_id)
            _params = {:grouping_id => grouping_id}
            return @master.call 'lists/interest-grouping-del', _params
        end

        # Update an existing Interest Grouping
        # @param [Int] grouping_id the interest grouping id - get from lists/interest-groupings()
        # @param [String] name The name of the field to update - either "name" or "type". Groups within the grouping should be manipulated using the standard listInterestGroup* methods
        # @param [String] value The new value of the field. Grouping names must be unique - only "hidden" and "checkboxes" grouping types can be converted between each other.
        # @return [Hash] with a single entry:
        #     - [Bool] complete whether the call worked. reallistically this will always be true as errors will be thrown otherwise.
        def interest_grouping_update(grouping_id, name, value)
            _params = {:grouping_id => grouping_id, :name => name, :value => value}
            return @master.call 'lists/interest-grouping-update', _params
        end

        # Retrieve the locations (countries) that the list's subscribers have been tagged to based on geocoding their IP address
        # @param [String] id the list id to connect to. Get by calling lists/list()
        # @return [Array] array of locations
        #     - [String] country the country name
        #     - [String] cc the ISO 3166 2 digit country code
        #     - [Double] percent the percent of subscribers in the country
        #     - [Double] total the total number of subscribers in the country
        def locations(id)
            _params = {:id => id}
            return @master.call 'lists/locations', _params
        end

        # Get the most recent 100 activities for particular list members (open, click, bounce, unsub, abuse, sent to, etc.)
        # @param [String] id the list id to connect to. Get by calling lists/list()
        # @param [Array] emails an array of up to 50 email structs, each with with one of the following keys
        #     - [String] email an email address - for new subscribers obviously this should be used
        #     - [String] euid the unique id for an email address (not list related) - the email "id" returned from listMemberInfo, Webhooks, Campaigns, etc.
        #     - [String] leid the list email id (previously called web_id) for a list-member-info type call. this doesn't change when the email address changes
        # @return [Hash] of data and success/error counts
        #     - [Int] success_count the number of subscribers successfully found on the list
        #     - [Int] error_count the number of subscribers who were not found on the list
        #     - [Array] errors array of error structs including:
        #         - [String] email whatever was passed in the email parameter
        #             - [String] email the email address added
        #             - [String] euid the email unique id
        #             - [String] leid the list member's truly unique id
        #         - [String] error the error message
        #         - [String] code the error code
        #     - [Array] data an array of structs where each activity record has:
        #         - [String] email whatever was passed in the email parameter
        #             - [String] email the email address added
        #             - [String] euid the email unique id
        #             - [String] leid the list member's truly unique id
        #         - [Array] activity an array of structs containing the activity, including:
        #             - [String] action The action name, one of: open, click, bounce, unsub, abuse, sent, queued, ecomm, mandrill_send, mandrill_hard_bounce, mandrill_soft_bounce, mandrill_open, mandrill_click, mandrill_spam, mandrill_unsub, mandrill_reject
        #             - [String] timestamp The date+time of the action (GMT)
        #             - [String] url For click actions, the url clicked, otherwise this is empty
        #             - [String] type If there's extra bounce, unsub, etc data it will show up here.
        #             - [String] campaign_id The campaign id the action was related to, if it exists - otherwise empty (ie, direct unsub from list)
        #             - [Hash] campaign_data If not deleted, the campaigns/list data for the campaign
        def member_activity(id, emails)
            _params = {:id => id, :emails => emails}
            return @master.call 'lists/member-activity', _params
        end

        # Get all the information for particular members of a list
        # @param [String] id the list id to connect to. Get by calling lists/list()
        # @param [Array] emails an array of up to 50 email structs, each with with one of the following keys
        #     - [String] email an email address - for new subscribers obviously this should be used
        #     - [String] euid the unique id for an email address (not list related) - the email "id" returned from listMemberInfo, Webhooks, Campaigns, etc.
        #     - [String] leid the list email id (previously called web_id) for a list-member-info type call. this doesn't change when the email address changes
        # @return [Hash] of data and success/error counts
        #     - [Int] success_count the number of subscribers successfully found on the list
        #     - [Int] error_count the number of subscribers who were not found on the list
        #     - [Array] errors array of error structs including:
        #         - [Hash] email whatever was passed in the email parameter
        #             - [String] email the email address added
        #             - [String] euid the email unique id
        #             - [String] leid the list member's truly unique id
        #         - [String] error the error message
        #     - [Array] data array of structs for each valid list member
        #         - [String] id The unique id (euid) for this email address on an account
        #         - [String] email The email address associated with this record
        #         - [String] email_type The type of emails this customer asked to get: html or text
        #         - [Hash] merges a struct containing a key for each merge tags and the data for those tags for this email address, plus:
        #             - [Array] GROUPINGS if Interest groupings are enabled, this will exist with structs for each grouping:
        #                 - [Int] id the grouping id
        #                 - [String] name the interest group name
        #                 - [Array] groups structs for each group in the grouping
        #                     - [String] name the group name
        #                     - [Bool] interested whether the member has this group selected
        #         - [String] status The subscription status for this email address, either pending, subscribed, unsubscribed, or cleaned
        #         - [String] ip_signup IP Address this address signed up from. This may be blank if single optin is used.
        #         - [String] timestamp_signup The date+time the double optin was initiated. This may be blank if single optin is used.
        #         - [String] ip_opt IP Address this address opted in from.
        #         - [String] timestamp_opt The date+time the optin completed
        #         - [Int] member_rating the rating of the subscriber. This will be 1 - 5 as described <a href="http://eepurl.com/f-2P" target="_blank">here</a>
        #         - [String] campaign_id If the user is unsubscribed and they unsubscribed from a specific campaign, that campaign_id will be listed, otherwise this is not returned.
        #         - [Array] lists An array of structs for the other lists this member belongs to
        #             - [String] id the list id
        #             - [String] status the members status on that list
        #         - [String] timestamp The date+time this email address entered it's current status
        #         - [String] info_changed The last time this record was changed. If the record is old enough, this may be blank.
        #         - [Int] web_id The Member id used in our web app, allows you to create a link directly to it
        #         - [Int] leid The Member id used in our web app, allows you to create a link directly to it
        #         - [String] list_id The list id the for the member record being returned
        #         - [String] list_name The list name the for the member record being returned
        #         - [String] language if set/detected, a language code from <a href="http://kb.mailchimp.com/article/can-i-see-what-languages-my-subscribers-use#code" target="_blank">here</a>
        #         - [Bool] is_gmonkey Whether the member is a <a href="http://mailchimp.com/features/golden-monkeys/" target="_blank">Golden Monkey</a> or not.
        #         - [Hash] geo the geographic information if we have it. including:
        #             - [String] latitude the latitude
        #             - [String] longitude the longitude
        #             - [String] gmtoff GMT offset
        #             - [String] dstoff GMT offset during daylight savings (if DST not observered, will be same as gmtoff)
        #             - [String] timezone the timezone we've place them in
        #             - [String] cc 2 digit ISO-3166 country code
        #             - [String] region generally state, province, or similar
        #         - [Hash] clients the client we've tracked the address as using with two keys:
        #             - [String] name the common name of the client
        #             - [String] icon_url a url representing a path to an icon representing this client
        #         - [Array] static_segments structs for each static segments the member is a part of including:
        #             - [Int] id the segment id
        #             - [String] name the name given to the segment
        #             - [String] added the date the member was added
        #         - [Array] notes structs for each note entered for this member. For each note:
        #             - [Int] id the note id
        #             - [String] note the text entered
        #             - [String] created the date the note was created
        #             - [String] updated the date the note was last updated
        #             - [String] created_by_name the name of the user who created the note. This can change as users update their profile.
        def member_info(id, emails)
            _params = {:id => id, :emails => emails}
            return @master.call 'lists/member-info', _params
        end

        # Get all of the list members for a list that are of a particular status and potentially matching a segment. This will cause locking, so don't run multiples at once. Are you trying to get a dump including lots of merge data or specific members of a list? If so, checkout the <a href="/export/1.0/list.func.php">List Export API</a>
        # @param [String] id the list id to connect to. Get by calling lists/list()
        # @param [String] status the status to get members for - one of(subscribed, unsubscribed, <a target="_blank" href="http://eepurl.com/gWOO">cleaned</a>), defaults to subscribed
        # @param [Hash] opts various options for controlling returned data
        #     - [Int] start optional for large data sets, the page number to start at - defaults to 1st page of data  (page 0)
        #     - [Int] limit optional for large data sets, the number of results to return - defaults to 25, upper limit set at 100
        #     - [String] sort_field optional the data field to sort by - mergeX (1-30), your custom merge tags, "email", "rating","last_update_time", or "optin_time" - invalid fields will be ignored
        #     - [String] sort_dir optional the direct - ASC or DESC. defaults to ASC (case insensitive)
        #     - [Hash] segment a properly formatted segment that works with campaigns/segment-test
        # @return [Hash] of the total records matched and limited list member data for this page
        #     - [Int] total the total matching records
        #     - [Array] data structs for each member as returned by member-info
        def members(id, status='subscribed', opts=[])
            _params = {:id => id, :status => status, :opts => opts}
            return @master.call 'lists/members', _params
        end

        # Add a new merge tag to a given list
        # @param [String] id the list id to connect to. Get by calling lists/list()
        # @param [String] tag The merge tag to add, e.g. FNAME. 10 bytes max, valid characters: "A-Z 0-9 _" no spaces, dashes, etc. Some tags and prefixes are <a href="http://kb.mailchimp.com/article/i-got-a-message-saying-that-my-list-field-name-is-reserved-and-cant-be-used" target="_blank">reserved</a>
        # @param [String] name The long description of the tag being added, used for user displays - max 50 bytes
        # @param [Hash] options optional Various options for this merge var
        #     - [String] field_type optional one of: text, number, radio, dropdown, date, address, phone, url, imageurl, zip, birthday - defaults to text
        #     - [Boolean] req optional indicates whether the field is required - defaults to false
        #     - [Boolean] public optional indicates whether the field is displayed in public - defaults to true
        #     - [Boolean] show optional indicates whether the field is displayed in the app's list member view - defaults to true
        #     - [Int] order The order this merge tag should be displayed in - this will cause existing values to be reset so this fits
        #     - [String] default_value optional the default value for the field. See lists/subscribe() for formatting info. Defaults to blank - max 255 bytes
        #     - [String] helptext optional the help text to be used with some newer forms. Defaults to blank - max 255 bytes
        #     - [Array] choices optional kind of - an array of strings to use as the choices for radio and dropdown type fields
        #     - [String] dateformat optional only valid for birthday and date fields. For birthday type, must be "MM/DD" (default) or "DD/MM". For date type, must be "MM/DD/YYYY" (default) or "DD/MM/YYYY". Any other values will be converted to the default.
        #     - [String] phoneformat optional "US" is the default - any other value will cause them to be unformatted (international)
        #     - [String] defaultcountry optional the <a href="http://www.iso.org/iso/english_country_names_and_code_elements" target="_blank">ISO 3166 2 digit character code</a> for the default country. Defaults to "US". Anything unrecognized will be converted to the default.
        # @return [Hash] the full data for the new merge var, just like merge-vars returns
        #     - [String] name Name/description of the merge field
        #     - [Bool] req Denotes whether the field is required (true) or not (false)
        #     - [String] field_type The "data type" of this merge var. One of: email, text, number, radio, dropdown, date, address, phone, url, imageurl
        #     - [Bool] public Whether or not this field is visible to list subscribers
        #     - [Bool] show Whether the field is displayed in thelist dashboard
        #     - [String] order The order this field displays in on forms
        #     - [String] default The default value for this field
        #     - [String] helptext The helptext for this field
        #     - [String] size The width of the field to be used
        #     - [String] tag The merge tag that's used for forms and lists/subscribe() and lists/update-member()
        #     - [Array] choices the options available for radio and dropdown field types
        #     - [Int] id an unchanging id for the merge var
        def merge_var_add(id, tag, name, options=[])
            _params = {:id => id, :tag => tag, :name => name, :options => options}
            return @master.call 'lists/merge-var-add', _params
        end

        # Delete a merge tag from a given list and all its members. Seriously - the data is removed from all members as well! Note that on large lists this method may seem a bit slower than calls you typically make.
        # @param [String] id the list id to connect to. Get by calling lists/list()
        # @param [String] tag The merge tag to delete
        # @return [Hash] with a single entry:
        #     - [Bool] complete whether the call worked. reallistically this will always be true as errors will be thrown otherwise.
        def merge_var_del(id, tag)
            _params = {:id => id, :tag => tag}
            return @master.call 'lists/merge-var-del', _params
        end

        # Completely resets all data stored in a merge var on a list. All data is removed and this action can not be undone.
        # @param [String] id the list id to connect to. Get by calling lists/list()
        # @param [String] tag The merge tag to reset
        # @return [Hash] with a single entry:
        #     - [Bool] complete whether the call worked. reallistically this will always be true as errors will be thrown otherwise.
        def merge_var_reset(id, tag)
            _params = {:id => id, :tag => tag}
            return @master.call 'lists/merge-var-reset', _params
        end

        # Sets a particular merge var to the specified value for every list member. Only merge var ids 1 - 30 may be modified this way. This is generally a dirty method unless you're fixing data since you should probably be using default_values and/or conditional content. as with lists/merge-var-reset(), this can not be undone.
        # @param [String] id the list id to connect to. Get by calling lists/list()
        # @param [String] tag The merge tag to reset
        # @param [String] value The value to set - see lists/subscribe() for formatting. Must validate to something non-empty.
        # @return [Hash] with a single entry:
        #     - [Bool] complete whether the call worked. reallistically this will always be true as errors will be thrown otherwise.
        def merge_var_set(id, tag, value)
            _params = {:id => id, :tag => tag, :value => value}
            return @master.call 'lists/merge-var-set', _params
        end

        # Update most parameters for a merge tag on a given list. You cannot currently change the merge type
        # @param [String] id the list id to connect to. Get by calling lists/list()
        # @param [String] tag The merge tag to update
        # @param [Hash] options The options to change for a merge var. See lists/merge-var-add() for valid options. "tag" and "name" may also be used here.
        # @return [Hash] the full data for the new merge var, just like merge-vars returns
        #     - [String] name Name/description of the merge field
        #     - [Bool] req Denotes whether the field is required (true) or not (false)
        #     - [String] field_type The "data type" of this merge var. One of: email, text, number, radio, dropdown, date, address, phone, url, imageurl
        #     - [Bool] public Whether or not this field is visible to list subscribers
        #     - [Bool] show Whether the field is displayed in thelist dashboard
        #     - [String] order The order this field to displays in on forms
        #     - [String] default The default value for this field
        #     - [String] helptext The helptext for this field
        #     - [String] size The width of the field to be used
        #     - [String] tag The merge tag that's used for forms and lists/subscribe() and lists/update-member()
        #     - [Array] choices the options available for radio and dropdown field types
        #     - [Int] id an unchanging id for the merge var
        def merge_var_update(id, tag, options)
            _params = {:id => id, :tag => tag, :options => options}
            return @master.call 'lists/merge-var-update', _params
        end

        # Get the list of merge tags for a given list, including their name, tag, and required setting
        # @param [Array] id the list ids to retrieve merge vars for. Get by calling lists/list() - max of 100
        # @return [Hash] of data and success/error counts
        #     - [Int] success_count the number of subscribers successfully found on the list
        #     - [Int] error_count the number of subscribers who were not found on the list
        #     - [Array] data of structs for the merge tags on each list
        #         - [String] id the list id
        #         - [String] name the list name
        #         - [Array] merge_vars of structs for each merge var
        #             - [String] name Name of the merge field
        #             - [Bool] req Denotes whether the field is required (true) or not (false)
        #             - [String] field_type The "data type" of this merge var. One of the options accepted by field_type in lists/merge-var-add
        #             - [Bool] public Whether or not this field is visible to list subscribers
        #             - [Bool] show Whether the list owner has this field displayed on their list dashboard
        #             - [String] order The order the list owner has set this field to display in
        #             - [String] default The default value the list owner has set for this field
        #             - [String] helptext The helptext for this field
        #             - [String] size The width of the field to be used
        #             - [String] tag The merge tag that's used for forms and lists/subscribe() and listUpdateMember()
        #             - [Array] choices For radio and dropdown field types, an array of the options available
        #             - [Int] id an unchanging id for the merge var
        #     - [Array] errors of error structs
        #         - [String] id the passed list id that failed
        #         - [Int] code the resulting error code
        #         - [String] msg the resulting error message
        def merge_vars(id)
            _params = {:id => id}
            return @master.call 'lists/merge-vars', _params
        end

        # Retrieve all of Segments for a list.
        # @param [String] id the list id to connect to. Get by calling lists/list()
        # @param [String] type optional, if specified should be "static" or "saved" and will limit the returned entries to that type
        # @return [Hash] with 2 keys:
        #     - [Int] static.id the id of the segment
        #     - [String] created_date the date+time the segment was created
        #     - [String] last_update the date+time the segment was last updated (add or del)
        def segments(id, type=nil)
            _params = {:id => id, :type => type}
            return @master.call 'lists/segments', _params
        end

        # Save a segment against a list for later use. There is no limit to the number of segments which can be saved. Static Segments <strong>are not</strong> tied to any merge data, interest groups, etc. They essentially allow you to configure an unlimited number of custom segments which will have standard performance. When using proper segments, Static Segments are one of the available options for segmentation just as if you used a merge var (and they can be used with other segmentation options), though performance may degrade at that point. Saved Segments (called "auto-updating" in the app) are essentially just the match+conditions typically used.
        # @param [String] id the list id to connect to. Get by calling lists/list()
        # @param [Hash] opts various options for the new segment
        #     - [String] type either "static" or "saved"
        #     - [String] name a unique name per list for the segment - 100 byte maximum length, anything longer will throw an error
        #     - [Hash] segment_opts for "saved" only, the standard segment match+conditions, just like campaigns/segment-test
        #         - [String] match "any" or "all"
        #         - [Array] conditions structs for each condition, just like campaigns/segment-test
        # @return [Hash] with a single entry:
        #     - [Int] id the id of the new segment, otherwise an error will be thrown.
        def segment_add(id, opts)
            _params = {:id => id, :opts => opts}
            return @master.call 'lists/segment-add', _params
        end

        # Delete a segment. Note that this will, of course, remove any member affiliations with any static segments deleted
        # @param [String] id the list id to connect to. Get by calling lists/list()
        # @param [Int] seg_id the id of the static segment to delete - get from lists/static-segments()
        # @return [Hash] with a single entry:
        #     - [Bool] complete whether the call worked. reallistically this will always be true as errors will be thrown otherwise.
        def segment_del(id, seg_id)
            _params = {:id => id, :seg_id => seg_id}
            return @master.call 'lists/segment-del', _params
        end

        # Allows one to test their segmentation rules before creating a campaign using them - this is no different from campaigns/segment-test() and will eventually replace it. For the time being, the crazy segmenting condition documentation will continue to live over there.
        # @param [String] list_id the list to test segmentation on - get lists using lists/list()
        # @param [Hash] options with 1 or 2 keys:
        #     - [String] saved_segment_id a saved segment id from lists/segments() - this will take precendence, otherwise the match+conditions are required.
        #     - [String] match controls whether to use AND or OR when applying your options - expects "<strong>any</strong>" (for OR) or "<strong>all</strong>" (for AND)
        #     - [Array] conditions of up to 5 structs for different criteria to apply while segmenting. Each criteria row must contain 3 keys - "<strong>field</strong>", "<strong>op</strong>", and "<strong>value</strong>" - and possibly a fourth, "<strong>extra</strong>", based on these definitions:
        # @return [Hash] with a single entry:
        #     - [Int] total The total number of subscribers matching your segmentation options
        def segment_test(list_id, options)
            _params = {:list_id => list_id, :options => options}
            return @master.call 'lists/segment-test', _params
        end

        # Update an existing segment. The list and type can not be changed.
        # @param [String] id the list id to connect to. Get by calling lists/list()
        # @param [Int] seg_id the segment to updated. Get by calling lists/segments()
        # @param [Hash] opts various options to update
        #     - [String] name a unique name per list for the segment - 100 byte maximum length, anything longer will throw an error
        #     - [Hash] segment_opts for "saved" only, the standard segment match+conditions, just like campaigns/segment-test
        #         - [Hash] match "any" or "all"
        #         - [Array] conditions structs for each condition, just like campaigns/segment-test
        # @return [Hash] with a single entry:
        #     - [Bool] complete whether the call worked. reallistically this will always be true as errors will be thrown otherwise.
        def segment_update(id, seg_id, opts)
            _params = {:id => id, :seg_id => seg_id, :opts => opts}
            return @master.call 'lists/segment-update', _params
        end

        # Save a segment against a list for later use. There is no limit to the number of segments which can be saved. Static Segments <strong>are not</strong> tied to any merge data, interest groups, etc. They essentially allow you to configure an unlimited number of custom segments which will have standard performance. When using proper segments, Static Segments are one of the available options for segmentation just as if you used a merge var (and they can be used with other segmentation options), though performance may degrade at that point.
        # @param [String] id the list id to connect to. Get by calling lists/list()
        # @param [String] name a unique name per list for the segment - 100 byte maximum length, anything longer will throw an error
        # @return [Hash] with a single entry:
        #     - [Int] id the id of the new segment, otherwise an error will be thrown.
        def static_segment_add(id, name)
            _params = {:id => id, :name => name}
            return @master.call 'lists/static-segment-add', _params
        end

        # Delete a static segment. Note that this will, of course, remove any member affiliations with the segment
        # @param [String] id the list id to connect to. Get by calling lists/list()
        # @param [Int] seg_id the id of the static segment to delete - get from lists/static-segments()
        # @return [Hash] with a single entry:
        #     - [Bool] complete whether the call worked. reallistically this will always be true as errors will be thrown otherwise.
        def static_segment_del(id, seg_id)
            _params = {:id => id, :seg_id => seg_id}
            return @master.call 'lists/static-segment-del', _params
        end

        # Add list members to a static segment. It is suggested that you limit batch size to no more than 10,000 addresses per call. Email addresses must exist on the list in order to be included - this <strong>will not</strong> subscribe them to the list!
        # @param [String] id the list id to connect to. Get by calling lists/list()
        # @param [Int] seg_id the id of the static segment to modify - get from lists/static-segments()
        # @param [Array] batch an array of structs for   each address using the following keys:
        #     - [String] email an email address
        #     - [String] euid the unique id for an email address (not list related) - the email "id" returned from listMemberInfo, Webhooks, Campaigns, etc.
        #     - [String] leid the list email id (previously called web_id) for a list-member-info type call. this doesn't change when the email address changes
        # @return [Hash] an array with the results of the operation
        #     - [Int] success_count the total number of successful updates (will include members already in the segment)
        #     - [Array] errors structs for each error including:
        #         - [String] email whatever was passed in the email parameter
        #             - [String] email the email address added
        #             - [String] euid the email unique id
        #             - [String] leid the list member's truly unique id
        #         - [String] code the error code
        #         - [String] error the full error message
        def static_segment_members_add(id, seg_id, batch)
            _params = {:id => id, :seg_id => seg_id, :batch => batch}
            return @master.call 'lists/static-segment-members-add', _params
        end

        # Remove list members from a static segment. It is suggested that you limit batch size to no more than 10,000 addresses per call. Email addresses must exist on the list in order to be removed - this <strong>will not</strong> unsubscribe them from the list!
        # @param [String] id the list id to connect to. Get by calling lists/list()
        # @param [Int] seg_id the id of the static segment to delete - get from lists/static-segments()
        # @param [Array] batch an array of structs for each address using one of the following keys:
        #     - [String] email an email address
        #     - [String] euid the unique id for an email address (not list related) - the email "id" returned from listMemberInfo, Webhooks, Campaigns, etc.
        #     - [String] leid the list email id (previously called web_id) for a list-member-info type call. this doesn't change when the email address changes
        # @return [Hash] an array with the results of the operation
        #     - [Int] success_count the total number of successful removals
        #     - [Int] error_count the total number of unsuccessful removals
        #     - [Array] errors structs for each error including:
        #         - [String] email whatever was passed in the email parameter
        #             - [String] email the email address added
        #             - [String] euid the email unique id
        #             - [String] leid the list member's truly unique id
        #         - [String] code the error code
        #         - [String] error the full error message
        def static_segment_members_del(id, seg_id, batch)
            _params = {:id => id, :seg_id => seg_id, :batch => batch}
            return @master.call 'lists/static-segment-members-del', _params
        end

        # Resets a static segment - removes <strong>all</strong> members from the static segment. Note: does not actually affect list member data
        # @param [String] id the list id to connect to. Get by calling lists/list()
        # @param [Int] seg_id the id of the static segment to reset  - get from lists/static-segments()
        # @return [Hash] with a single entry:
        #     - [Bool] complete whether the call worked. reallistically this will always be true as errors will be thrown otherwise.
        def static_segment_reset(id, seg_id)
            _params = {:id => id, :seg_id => seg_id}
            return @master.call 'lists/static-segment-reset', _params
        end

        # Retrieve all of the Static Segments for a list.
        # @param [String] id the list id to connect to. Get by calling lists/list()
        # @return [Array] an of structs with data for each static segment
        #     - [Int] id the id of the segment
        #     - [String] name the name for the segment
        #     - [Int] member_count the total number of subscribed members currently in a segment
        #     - [String] created_date the date+time the segment was created
        #     - [String] last_update the date+time the segment was last updated (add or del)
        #     - [String] last_reset the date+time the segment was last reset (ie had all members cleared from it)
        def static_segments(id)
            _params = {:id => id}
            return @master.call 'lists/static-segments', _params
        end

        # Subscribe the provided email to a list. By default this sends a confirmation email - you will not see new members until the link contained in it is clicked!
        # @param [String] id the list id to connect to. Get by calling lists/list()
        # @param [Hash] email a struct with one of the following keys - failing to provide anything will produce an error relating to the email address. Providing multiples and will use the first we see in this same order.
        #     - [String] email an email address - for new subscribers obviously this should be used
        #     - [String] euid the unique id for an email address (not list related) - the email "id" returned from listMemberInfo, Webhooks, Campaigns, etc.
        #     - [String] leid the list email id (previously called web_id) for a list-member-info type call. this doesn't change when the email address changes
        # @param [Hash] merge_vars optional merges for the email (FNAME, LNAME, <a href="http://kb.mailchimp.com/article/where-can-i-find-my-lists-merge-tags target="_blank">etc.</a>) (see examples below for handling "blank" arrays). Note that a merge field can only hold up to 255 bytes. Also, there are a few "special" keys:
        #     - [String] new-email set this to change the email address. This is only respected on calls using update_existing or when passed to listUpdateMember().
        #     - [Array] groupings of Interest Grouping structs. Each should contain:
        #         - [Int] id Grouping "id" from lists/interest-groupings (either this or name must be present) - this id takes precedence and can't change (unlike the name)
        #         - [String] name Grouping "name" from lists/interest-groupings (either this or id must be present)
        #         - [Array] groups an array of valid group names for this grouping.
        #     - [String] optin_ip Set the Opt-in IP field. <em>Abusing this may cause your account to be suspended.</em> We do validate this and it must not be a private IP address.
        #     - [String] optin_time Set the Opt-in Time field. <em>Abusing this may cause your account to be suspended.</em> We do validate this and it must be a valid date. Use  - 24 hour format in <strong>GMT</strong>, eg "2013-12-30 20:30:00" to be safe. Generally, though, anything strtotime() understands we'll understand - <a href="http://us2.php.net/strtotime" target="_blank">http://us2.php.net/strtotime</a>
        #     - [Hash] mc_location Set the member's geographic location either by optin_ip or geo data.
        #         - [String] latitude use the specified latitude (longitude must exist for this to work)
        #         - [String] longitude use the specified longitude (latitude must exist for this to work)
        #         - [String] anything if this (or any other key exists here) we'll try to use the optin ip. NOTE - this will slow down each subscribe call a bit, especially for lat/lng pairs in sparsely populated areas. Currently our automated background processes can and will overwrite this based on opens and clicks.
        #     - [String] mc_language Set the member's language preference. Supported codes are fully case-sensitive and can be found <a href="http://kb.mailchimp.com/article/can-i-see-what-languages-my-subscribers-use#code" target="_new">here</a>.
        #     - [Array] mc_notes of structs for managing notes - it may contain:
        #         - [String] note the note to set. this is required unless you're deleting a note
        #         - [Int] id the note id to operate on. not including this (or using an invalid id) causes a new note to be added
        #         - [String] action if the "id" key exists and is valid, an "update" key may be set to "append" (default), "prepend", "replace", or "delete" to handle how we should update existing notes. "delete", obviously, will only work with a valid "id" - passing that along with "note" and an invalid "id" is wrong and will be ignored.
        # @param [String] email_type optional email type preference for the email (html or text - defaults to html)
        # @param [Bool] double_optin optional flag to control whether a double opt-in confirmation message is sent, defaults to true. <em>Abusing this may cause your account to be suspended.</em>
        # @param [Bool] update_existing optional flag to control whether existing subscribers should be updated instead of throwing an error, defaults to false
        # @param [Bool] replace_interests optional flag to determine whether we replace the interest groups with the groups provided or we add the provided groups to the member's interest groups (optional, defaults to true)
        # @param [Bool] send_welcome optional if your double_optin is false and this is true, we will send your lists Welcome Email if this subscribe succeeds - this will *not* fire if we end up updating an existing subscriber. If double_optin is true, this has no effect. defaults to false.
        # @return [Hash] the ids for this subscriber
        #     - [String] email the email address added
        #     - [String] euid the email unique id
        #     - [String] leid the list member's truly unique id
        def subscribe(id, email, merge_vars=nil, email_type='html', double_optin=true, update_existing=false, replace_interests=true, send_welcome=false)
            _params = {:id => id, :email => email, :merge_vars => merge_vars, :email_type => email_type, :double_optin => double_optin, :update_existing => update_existing, :replace_interests => replace_interests, :send_welcome => send_welcome}
            return @master.call 'lists/subscribe', _params
        end

        # Unsubscribe the given email address from the list
        # @param [String] id the list id to connect to. Get by calling lists/list()
        # @param [Hash] email a struct with one of the following keys - failing to provide anything will produce an error relating to the email address. Providing multiples and will use the first we see in this same order.
        #     - [String] email an email address
        #     - [String] euid the unique id for an email address (not list related) - the email "id" returned from listMemberInfo, Webhooks, Campaigns, etc.
        #     - [String] leid the list email id (previously called web_id) for a list-member-info type call. this doesn't change when the email address changes
        # @param [Boolean] delete_member flag to completely delete the member from your list instead of just unsubscribing, default to false
        # @param [Boolean] send_goodbye flag to send the goodbye email to the email address, defaults to true
        # @param [Boolean] send_notify flag to send the unsubscribe notification email to the address defined in the list email notification settings, defaults to true
        # @return [Hash] with a single entry:
        #     - [Bool] complete whether the call worked. reallistically this will always be true as errors will be thrown otherwise.
        def unsubscribe(id, email, delete_member=false, send_goodbye=true, send_notify=true)
            _params = {:id => id, :email => email, :delete_member => delete_member, :send_goodbye => send_goodbye, :send_notify => send_notify}
            return @master.call 'lists/unsubscribe', _params
        end

        # Edit the email address, merge fields, and interest groups for a list member. If you are doing a batch update on lots of users, consider using lists/batch-subscribe() with the update_existing and possible replace_interests parameter.
        # @param [String] id the list id to connect to. Get by calling lists/list()
        # @param [Hash] email a struct with one of the following keys - failing to provide anything will produce an error relating to the email address. Providing multiples and will use the first we see in this same order.
        #     - [String] email an email address
        #     - [String] euid the unique id for an email address (not list related) - the email "id" returned from listMemberInfo, Webhooks, Campaigns, etc.
        #     - [String] leid the list email id (previously called web_id) for a list-member-info type call. this doesn't change when the email address changes
        # @param [Array] merge_vars array of new field values to update the member with.  See merge_vars in lists/subscribe() for details.
        # @param [String] email_type change the email type preference for the member ("html" or "text").  Leave blank to keep the existing preference (optional)
        # @param [Boolean] replace_interests flag to determine whether we replace the interest groups with the updated groups provided, or we add the provided groups to the member's interest groups (optional, defaults to true)
        # @return [Hash] the ids for this subscriber
        #     - [String] email the email address added
        #     - [String] euid the email unique id
        #     - [String] leid the list member's truly unique id
        def update_member(id, email, merge_vars, email_type='', replace_interests=true)
            _params = {:id => id, :email => email, :merge_vars => merge_vars, :email_type => email_type, :replace_interests => replace_interests}
            return @master.call 'lists/update-member', _params
        end

        # Add a new Webhook URL for the given list
        # @param [String] id the list id to connect to. Get by calling lists/list()
        # @param [String] url a valid URL for the Webhook - it will be validated. note that a url may only exist on a list once.
        # @param [Hash] actions optional a hash of actions to fire this Webhook for
        #     - [Bool] subscribe optional as subscribes occur, defaults to true
        #     - [Bool] unsubscribe optional as subscribes occur, defaults to true
        #     - [Bool] profile optional as profile updates occur, defaults to true
        #     - [Bool] cleaned optional as emails are cleaned from the list, defaults to true
        #     - [Bool] upemail optional when  subscribers change their email address, defaults to true
        #     - [Bool] campaign option when a campaign is sent or canceled, defaults to true
        # @param [Hash] sources optional  sources to fire this Webhook for
        #     - [Bool] user optional user/subscriber initiated actions, defaults to true
        #     - [Bool] admin optional admin actions in our web app, defaults to true
        #     - [Bool] api optional actions that happen via API calls, defaults to false
        # @return [Hash] with a single entry:
        #     - [Int] id the id of the new webhook, otherwise an error will be thrown.
        def webhook_add(id, url, actions=[], sources=[])
            _params = {:id => id, :url => url, :actions => actions, :sources => sources}
            return @master.call 'lists/webhook-add', _params
        end

        # Delete an existing Webhook URL from a given list
        # @param [String] id the list id to connect to. Get by calling lists/list()
        # @param [String] url the URL of a Webhook on this list
        # @return [Hash] with a single entry:
        #     - [Bool] complete whether the call worked. reallistically this will always be true as errors will be thrown otherwise.
        def webhook_del(id, url)
            _params = {:id => id, :url => url}
            return @master.call 'lists/webhook-del', _params
        end

        # Return the Webhooks configured for the given list
        # @param [String] id the list id to connect to. Get by calling lists/list()
        # @return [Array] of structs for each webhook
        #     - [String] url the URL for this Webhook
        #     - [Hash] actions the possible actions and whether they are enabled
        #         - [Bool] subscribe triggered when subscribes happen
        #         - [Bool] unsubscribe triggered when unsubscribes happen
        #         - [Bool] profile triggered when profile updates happen
        #         - [Bool] cleaned triggered when a subscriber is cleaned (bounced) from a list
        #         - [Bool] upemail triggered when a subscriber's email address is changed
        #         - [Bool] campaign triggered when a campaign is sent or canceled
        #     - [Hash] sources the possible sources and whether they are enabled
        #         - [Bool] user whether user/subscriber triggered actions are returned
        #         - [Bool] admin whether admin (manual, in-app) triggered actions are returned
        #         - [Bool] api whether api triggered actions are returned
        def webhooks(id)
            _params = {:id => id}
            return @master.call 'lists/webhooks', _params
        end

        # Retrieve all of the lists defined for your user account
        # @param [Hash] filters filters to apply to this query - all are optional:
        #     - [String] list_id optional - return a single list using a known list_id. Accepts multiples separated by commas when not using exact matching
        #     - [String] list_name optional - only lists that match this name
        #     - [String] from_name optional - only lists that have a default from name matching this
        #     - [String] from_email optional - only lists that have a default from email matching this
        #     - [String] from_subject optional - only lists that have a default from email matching this
        #     - [String] created_before optional - only show lists that were created before this date+time  - 24 hour format in <strong>GMT</strong>, eg "2013-12-30 20:30:00"
        #     - [String] created_after optional - only show lists that were created since this date+time  - 24 hour format in <strong>GMT</strong>, eg "2013-12-30 20:30:00"
        #     - [Boolean] exact optional - flag for whether to filter on exact values when filtering, or search within content for filter values - defaults to true
        # @param [Int] start optional - control paging of lists, start results at this list #, defaults to 1st page of data  (page 0)
        # @param [Int] limit optional - control paging of lists, number of lists to return with each call, defaults to 25 (max=100)
        # @param [String] sort_field optional - "created" (the created date, default) or "web" (the display order in the web app). Invalid values will fall back on "created" - case insensitive.
        # @param [String] sort_dir optional - "DESC" for descending (default), "ASC" for Ascending.  Invalid values will fall back on "created" - case insensitive. Note: to get the exact display order as the web app you'd use "web" and "ASC"
        # @return [Hash] result of the operation including valid data and any errors
        #     - [Int] total the total number of lists which matched the provided filters
        #     - [Array] data structs for the lists which matched the provided filters, including the following
        #         - [String] id The list id for this list. This will be used for all other list management functions.
        #         - [Int] web_id The list id used in our web app, allows you to create a link directly to it
        #         - [String] name The name of the list.
        #         - [String] date_created The date that this list was created.
        #         - [Boolean] email_type_option Whether or not the List supports multiple formats for emails or just HTML
        #         - [Boolean] use_awesomebar Whether or not campaigns for this list use the Awesome Bar in archives by default
        #         - [String] default_from_name Default From Name for campaigns using this list
        #         - [String] default_from_email Default From Email for campaigns using this list
        #         - [String] default_subject Default Subject Line for campaigns using this list
        #         - [String] default_language Default Language for this list's forms
        #         - [Double] list_rating An auto-generated activity score for the list (0 - 5)
        #         - [String] subscribe_url_short Our eepurl shortened version of this list's subscribe form (will not change)
        #         - [String] subscribe_url_long The full version of this list's subscribe form (host will vary)
        #         - [String] beamer_address The email address to use for this list's <a href="http://kb.mailchimp.com/article/how-do-i-import-a-campaign-via-email-email-beamer/">Email Beamer</a>
        #         - [String] visibility Whether this list is Public (pub) or Private (prv). Used internally for projects like <a href="http://blog.mailchimp.com/introducing-wavelength/" target="_blank">Wavelength</a>
        #         - [Hash] stats various stats and counts for the list - many of these are cached for at least 5 minutes
        #             - [Double] member_count The number of active members in the given list.
        #             - [Double] unsubscribe_count The number of members who have unsubscribed from the given list.
        #             - [Double] cleaned_count The number of members cleaned from the given list.
        #             - [Double] member_count_since_send The number of active members in the given list since the last campaign was sent
        #             - [Double] unsubscribe_count_since_send The number of members who have unsubscribed from the given list since the last campaign was sent
        #             - [Double] cleaned_count_since_send The number of members cleaned from the given list since the last campaign was sent
        #             - [Double] campaign_count The number of campaigns in any status that use this list
        #             - [Double] grouping_count The number of Interest Groupings for this list
        #             - [Double] group_count The number of Interest Groups (regardless of grouping) for this list
        #             - [Double] merge_var_count The number of merge vars for this list (not including the required EMAIL one)
        #             - [Double] avg_sub_rate the average number of subscribe per month for the list (empty value if we haven't calculated this yet)
        #             - [Double] avg_unsub_rate the average number of unsubscribe per month for the list (empty value if we haven't calculated this yet)
        #             - [Double] target_sub_rate the target subscription rate for the list to keep it growing (empty value if we haven't calculated this yet)
        #             - [Double] open_rate the average open rate per campaign for the list  (empty value if we haven't calculated this yet)
        #             - [Double] click_rate the average click rate per campaign for the list  (empty value if we haven't calculated this yet)
        #         - [Array] modules Any list specific modules installed for this list (example is SocialPro)
        #     - [Array] errors structs of any errors found while loading lists - usually just from providing invalid list ids
        #         - [String] param the data that caused the failure
        #         - [Int] code the error code
        #         - [Int] error the error message
        def list(filters=[], start=0, limit=25, sort_field='created', sort_dir='DESC')
            _params = {:filters => filters, :start => start, :limit => limit, :sort_field => sort_field, :sort_dir => sort_dir}
            return @master.call 'lists/list', _params
        end

    end
    class Campaigns
        attr_accessor :master

        def initialize(master)
            @master = master
        end

        # Get the content (both html and text) for a campaign either as it would appear in the campaign archive or as the raw, original content
        # @param [String] cid the campaign id to get content for (can be gathered using campaigns/list())
        # @param [Hash] options various options to control this call
        #     - [String] view optional one of "archive" (default), "preview" (like our popup-preview) or "raw"
        #     - [Hash] email optional if provided, view is "archive" or "preview", the campaign's list still exists, and the requested record is subscribed to the list. the returned content will be populated with member data populated. a struct with one of the following keys - failing to provide anything will produce an error relating to the email address. Providing multiples and will use the first we see in this same order.
        #         - [String] email an email address
        #         - [String] euid the unique id for an email address (not list related) - the email "id" returned from listMemberInfo, Webhooks, Campaigns, etc.
        #         - [String] leid the list email id (previously called web_id) for a list-member-info type call. this doesn't change when the email address changes
        # @return [Hash] containing all content for the campaign
        #     - [String] html The HTML content used for the campaign with merge tags intact
        #     - [String] text The Text content used for the campaign with merge tags intact
        def content(cid, options=[])
            _params = {:cid => cid, :options => options}
            return @master.call 'campaigns/content', _params
        end

        # Create a new draft campaign to send. You <strong>can not</strong> have more than 32,000 campaigns in your account.
        # @param [String] type the Campaign Type to create - one of "regular", "plaintext", "absplit", "rss", "auto"
        # @param [Hash] options a struct of the standard options for this campaign :
        #     - [String] list_id the list to send this campaign to- get lists using lists/list()
        #     - [String] subject the subject line for your campaign message
        #     - [String] from_email the From: email address for your campaign message
        #     - [String] from_name the From: name for your campaign message (not an email address)
        #     - [String] to_name the To: name recipients will see (not email address)
        #     - [Int] template_id optional - use this user-created template to generate the HTML content of the campaign (takes precendence over other template options)
        #     - [Int] gallery_template_id optional - use a template from the public gallery to generate the HTML content of the campaign (takes precendence over base template options)
        #     - [Int] base_template_id optional - use this a base/start-from-scratch template to generate the HTML content of the campaign
        #     - [Int] folder_id optional - automatically file the new campaign in the folder_id passed. Get using folders/list() - note that Campaigns and Autoresponders have separate folder setups
        #     - [Hash] tracking optional - set which recipient actions will be tracked. Click tracking can not be disabled for Free accounts.
        #         - [Bool] opens whether to track opens, defaults to true
        #         - [Bool] html_clicks whether to track clicks in HTML content, defaults to true
        #         - [Bool] text_clicks whether to track clicks in Text content, defaults to false
        #     - [String] title optional - an internal name to use for this campaign.  By default, the campaign subject will be used.
        #     - [Boolean] authenticate optional - set to true to enable SenderID, DomainKeys, and DKIM authentication, defaults to false.
        #     - [Hash] analytics optional - one or more of these keys set to the tag to use - that can be any custom text (up to 50 bytes)
        #         - [String] google for Google Analytics  tracking
        #         - [String] clicktale for ClickTale  tracking
        #         - [String] gooal for Goo.al tracking
        #     - [Boolean] auto_footer optional Whether or not we should auto-generate the footer for your content. Mostly useful for content from URLs or Imports
        #     - [Boolean] inline_css optional Whether or not css should be automatically inlined when this campaign is sent, defaults to false.
        #     - [Boolean] generate_text optional Whether of not to auto-generate your Text content from the HTML content. Note that this will be ignored if the Text part of the content passed is not empty, defaults to false.
        #     - [Boolean] auto_tweet optional If set, this campaign will be auto-tweeted when it is sent - defaults to false. Note that if a Twitter account isn't linked, this will be silently ignored.
        #     - [Array] auto_fb_post optional If set, this campaign will be auto-posted to the page_ids contained in the array. If a Facebook account isn't linked or the account does not have permission to post to the page_ids requested, those failures will be silently ignored.
        #     - [Boolean] fb_comments optional If true, the Facebook comments (and thus the <a href="http://kb.mailchimp.com/article/i-dont-want-an-archiave-of-my-campaign-can-i-turn-it-off/" target="_blank">archive bar</a> will be displayed. If false, Facebook comments will not be enabled (does not imply no archive bar, see previous link). Defaults to "true".
        #     - [Boolean] timewarp optional If set, this campaign must be scheduled 24 hours in advance of sending - default to false. Only valid for "regular" campaigns and "absplit" campaigns that split on schedule_time.
        #     - [Boolean] ecomm360 optional If set, our <a href="http://www.mailchimp.com/blog/ecommerce-tracking-plugin/" target="_blank">Ecommerce360 tracking</a> will be enabled for links in the campaign
        #     - [Array] crm_tracking optional If set, an array of structs to enable CRM tracking for:
        #         - [Hash] salesforce optional Enable SalesForce push back
        #             - [Bool] campaign optional - if true, create a Campaign object and update it with aggregate stats
        #             - [Bool] notes optional - if true, attempt to update Contact notes based on email address
        #         - [Hash] highrise optional Enable Highrise push back
        #             - [Bool] campaign optional - if true, create a Kase object and update it with aggregate stats
        #             - [Bool] notes optional - if true, attempt to update Contact notes based on email address
        #         - [Hash] capsule optional Enable Capsule push back (only notes are supported)
        #             - [Bool] notes optional - if true, attempt to update Contact notes based on email address
        # @param [Hash] content the content for this campaign - use a struct with the one of the following keys:
        #     - [String] html for raw/pasted HTML content
        #     - [Hash] sections when using a template instead of raw HTML, each key should be the unique mc:edit area name from the template.
        #     - [String] text for the plain-text version
        #     - [String] url to have us pull in content from a URL. Note, this will override any other content options - for lists with Email Format options, you'll need to turn on generate_text as well
        #     - [String] archive to send a Base64 encoded archive file for us to import all media from. Note, this will override any other content options - for lists with Email Format options, you'll need to turn on generate_text as well
        #     - [String] archive_type optional - only necessary for the "archive" option. Supported formats are: zip, tar.gz, tar.bz2, tar, tgz, tbz . If not included, we will default to zip
        # @param [Hash] segment_opts if you wish to do Segmentation with this campaign this array should contain: see campaigns/segment-test(). It's suggested that you test your options against campaigns/segment-test().
        # @param [Hash] type_opts various extra options based on the campaign type
        #     - [Hash] rss For RSS Campaigns this, struct should contain:
        #         - [String] url the URL to pull RSS content from - it will be verified and must exist
        #         - [String] schedule optional one of "daily", "weekly", "monthly" - defaults to "daily"
        #         - [String] schedule_hour optional an hour between 0 and 24 - default to 4 (4am <em>local time</em>) - applies to all schedule types
        #         - [String] schedule_weekday optional for "weekly" only, a number specifying the day of the week to send: 0 (Sunday) - 6 (Saturday) - defaults to 1 (Monday)
        #         - [String] schedule_monthday optional for "monthly" only, a number specifying the day of the month to send (1 - 28) or "last" for the last day of a given month. Defaults to the 1st day of the month
        #         - [Hash] days optional used for "daily" schedules only, an array of the <a href="http://en.wikipedia.org/wiki/ISO-8601#Week_dates" target="_blank">ISO-8601 weekday numbers</a> to send on
        #             - [Bool] 1 optional Monday, defaults to true
        #             - [Bool] 2 optional Tuesday, defaults to true
        #             - [Bool] 3 optional Wednesday, defaults to true
        #             - [Bool] 4 optional Thursday, defaults to true
        #             - [Bool] 5 optional Friday, defaults to true
        #             - [Bool] 6 optional Saturday, defaults to true
        #             - [Bool] 7 optional Sunday, defaults to true
        #     - [Hash] absplit For A/B Split campaigns, this struct should contain:
        #         - [String] split_test The values to segment based on. Currently, one of: "subject", "from_name", "schedule". NOTE, for "schedule", you will need to call campaigns/schedule() separately!
        #         - [String] pick_winner How the winner will be picked, one of: "opens" (by the open_rate), "clicks" (by the click rate), "manual" (you pick manually)
        #         - [Int] wait_units optional the default time unit to wait before auto-selecting a winner - use "3600" for hours, "86400" for days. Defaults to 86400.
        #         - [Int] wait_time optional the number of units to wait before auto-selecting a winner - defaults to 1, so if not set, a winner will be selected after 1 Day.
        #         - [Int] split_size optional this is a percentage of what size the Campaign's List plus any segmentation options results in. "schedule" type forces 50%, all others default to 10%
        #         - [String] from_name_a optional sort of, required when split_test is "from_name"
        #         - [String] from_name_b optional sort of, required when split_test is "from_name"
        #         - [String] from_email_a optional sort of, required when split_test is "from_name"
        #         - [String] from_email_b optional sort of, required when split_test is "from_name"
        #         - [String] subject_a optional sort of, required when split_test is "subject"
        #         - [String] subject_b optional sort of, required when split_test is "subject"
        #     - [Hash] auto For AutoResponder campaigns, this struct should contain:
        #         - [String] offset-units one of "hourly", "day", "week", "month", "year" - required
        #         - [String] offset-time optional, sort of - the number of units must be a number greater than 0 for signup based autoresponders, ignored for "hourly"
        #         - [String] offset-dir either "before" or "after", ignored for "hourly"
        #         - [String] event optional "signup" (default) to base this members added to a list, "date", "annual", or "birthday" to base this on merge field in the list, "campaignOpen" or "campaignClicka" to base this on any activity for a campaign, "campaignClicko" to base this on clicks on a specific URL in a campaign, "mergeChanged" to base this on a specific merge field being changed to a specific value
        #         - [String] event-datemerge optional sort of, this is required if the event is "date", "annual", "birthday", or "mergeChanged"
        #         - [String] campaign_id optional sort of, required for "campaignOpen", "campaignClicka", or "campaignClicko"
        #         - [String] campaign_url optional sort of, required for "campaignClicko"
        #         - [Int] schedule_hour The hour of the day - 24 hour format in GMT - the autoresponder should be triggered, ignored for "hourly"
        #         - [Boolean] use_import_time whether or not imported subscribers (ie, <em>any</em> non-double optin subscribers) will receive
        #         - [Hash] days optional used for "daily" schedules only, an array of the <a href="http://en.wikipedia.org/wiki/ISO-8601#Week_dates" target="_blank">ISO-8601 weekday numbers</a> to send on<
        #             - [Bool] 1 optional Monday, defaults to true
        #             - [Bool] 2 optional Tuesday, defaults to true
        #             - [Bool] 3 optional Wednesday, defaults to true
        #             - [Bool] 4 optional Thursday, defaults to true
        #             - [Bool] 5 optional Friday, defaults to true
        #             - [Bool] 6 optional Saturday, defaults to true
        #             - [Bool] 7 optional Sunday, defaults to true
        # @return [Hash] the new campaign's details - will return same data as single campaign from campaigns/list()
        def create(type, options, content, segment_opts=nil, type_opts=nil)
            _params = {:type => type, :options => options, :content => content, :segment_opts => segment_opts, :type_opts => type_opts}
            return @master.call 'campaigns/create', _params
        end

        # Delete a campaign. Seriously, "poof, gone!" - be careful! Seriously, no one can undelete these.
        # @param [String] cid the Campaign Id to delete
        # @return [Hash] with a single entry:
        #     - [Bool] complete whether the call worked. reallistically this will always be true as errors will be thrown otherwise.
        def delete(cid)
            _params = {:cid => cid}
            return @master.call 'campaigns/delete', _params
        end

        # Get the list of campaigns and their details matching the specified filters
        # @param [Hash] filters a struct of filters to apply to this query - all are optional:
        #     - [String] campaign_id optional - return the campaign using a know campaign_id.  Accepts multiples separated by commas when not using exact matching.
        #     - [String] parent_id optional - return the child campaigns using a known parent campaign_id.  Accepts multiples separated by commas when not using exact matching.
        #     - [String] list_id optional - the list to send this campaign to - get lists using lists/list(). Accepts multiples separated by commas when not using exact matching.
        #     - [Int] folder_id optional - only show campaigns from this folder id - get folders using folders/list(). Accepts multiples separated by commas when not using exact matching.
        #     - [Int] template_id optional - only show campaigns using this template id - get templates using templates/list(). Accepts multiples separated by commas when not using exact matching.
        #     - [String] status optional - return campaigns of a specific status - one of "sent", "save", "paused", "schedule", "sending". Accepts multiples separated by commas when not using exact matching.
        #     - [String] type optional - return campaigns of a specific type - one of "regular", "plaintext", "absplit", "rss", "auto". Accepts multiples separated by commas when not using exact matching.
        #     - [String] from_name optional - only show campaigns that have this "From Name"
        #     - [String] from_email optional - only show campaigns that have this "Reply-to Email"
        #     - [String] title optional - only show campaigns that have this title
        #     - [String] subject optional - only show campaigns that have this subject
        #     - [String] sendtime_start optional - only show campaigns that have been sent since this date/time (in GMT) -  - 24 hour format in <strong>GMT</strong>, eg "2013-12-30 20:30:00" - if this is invalid the whole call fails
        #     - [String] sendtime_end optional - only show campaigns that have been sent before this date/time (in GMT) -  - 24 hour format in <strong>GMT</strong>, eg "2013-12-30 20:30:00" - if this is invalid the whole call fails
        #     - [Boolean] uses_segment - whether to return just campaigns with or without segments
        #     - [Boolean] exact optional - flag for whether to filter on exact values when filtering, or search within content for filter values - defaults to true. Using this disables the use of any filters that accept multiples.
        # @param [Int] start optional - control paging of campaigns, start results at this campaign #, defaults to 1st page of data  (page 0)
        # @param [Int] limit optional - control paging of campaigns, number of campaigns to return with each call, defaults to 25 (max=1000)
        # @param [String] sort_field optional - one of "create_time", "send_time", "title", "subject" . Invalid values will fall back on "create_time" - case insensitive.
        # @param [String] sort_dir optional - "DESC" for descending (default), "ASC" for Ascending.  Invalid values will fall back on "DESC" - case insensitive.
        # @return [Hash] containing a count of all matching campaigns, the specific ones for the current page, and any errors from the filters provided
        #     - [Int] total the total number of campaigns matching the filters passed in
        #     - [Array] data structs for each campaign being returned
        #         - [String] id Campaign Id (used for all other campaign functions)
        #         - [Int] web_id The Campaign id used in our web app, allows you to create a link directly to it
        #         - [String] list_id The List used for this campaign
        #         - [Int] folder_id The Folder this campaign is in
        #         - [Int] template_id The Template this campaign uses
        #         - [String] content_type How the campaign's content is put together - one of 'template', 'html', 'url'
        #         - [String] title Title of the campaign
        #         - [String] type The type of campaign this is (regular,plaintext,absplit,rss,inspection,auto)
        #         - [String] create_time Creation time for the campaign
        #         - [String] send_time Send time for the campaign - also the scheduled time for scheduled campaigns.
        #         - [Int] emails_sent Number of emails email was sent to
        #         - [String] status Status of the given campaign (save,paused,schedule,sending,sent)
        #         - [String] from_name From name of the given campaign
        #         - [String] from_email Reply-to email of the given campaign
        #         - [String] subject Subject of the given campaign
        #         - [String] to_name Custom "To:" email string using merge variables
        #         - [String] archive_url Archive link for the given campaign
        #         - [Boolean] inline_css Whether or not the campaign content's css was auto-inlined
        #         - [String] analytics Either "google" if enabled or "N" if disabled
        #         - [String] analytics_tag The name/tag the campaign's links were tagged with if analytics were enabled.
        #         - [Boolean] authenticate Whether or not the campaign was authenticated
        #         - [Boolean] ecomm360 Whether or not ecomm360 tracking was appended to links
        #         - [Boolean] auto_tweet Whether or not the campaign was auto tweeted after sending
        #         - [String] auto_fb_post A comma delimited list of Facebook Profile/Page Ids the campaign was posted to after sending. If not used, blank.
        #         - [Boolean] auto_footer Whether or not the auto_footer was manually turned on
        #         - [Boolean] timewarp Whether or not the campaign used Timewarp
        #         - [String] timewarp_schedule The time, in GMT, that the Timewarp campaign is being sent. For A/B Split campaigns, this is blank and is instead in their schedule_a and schedule_b in the type_opts array
        #         - [String] parent_id the unique id of the parent campaign (currently only valid for rss children)
        #         - [String] tests_sent tests sent
        #         - [String] tests_remain test sends remaining
        #         - [Hash] tracking the various tracking options used
        #             - [Boolean] html_clicks whether or not tracking for html clicks was enabled.
        #             - [Boolean] text_clicks whether or not tracking for text clicks was enabled.
        #             - [Boolean] opens whether or not opens tracking was enabled.
        #         - [String] segment_text a string marked-up with HTML explaining the segment used for the campaign in plain English
        #         - [Array] segment_opts the segment used for the campaign - can be passed to campaigns/segment-test or campaigns/create()
        #         - [Hash] saved_segment if a saved segment was used (match+conditions returned above):
        #             - [Hash] id the saved segment id
        #             - [Hash] type the saved segment type
        #             - [Hash] name the saved segment name
        #         - [Hash] type_opts the type-specific options for the campaign - can be passed to campaigns/create()
        #         - [Int] comments_total total number of comments left on this campaign
        #         - [Int] comments_unread total number of unread comments for this campaign based on the login the apikey belongs to
        #         - [Hash] summary if available, the basic aggregate stats returned by reports/summary
        #     - [Array] errors structs of any errors found while loading lists - usually just from providing invalid list ids
        #         - [String] filter the filter that caused the failure
        #         - [String] value the filter value that caused the failure
        #         - [Int] code the error code
        #         - [Int] error the error message
        def list(filters=[], start=0, limit=25, sort_field='create_time', sort_dir='DESC')
            _params = {:filters => filters, :start => start, :limit => limit, :sort_field => sort_field, :sort_dir => sort_dir}
            return @master.call 'campaigns/list', _params
        end

        # Pause an AutoResponder or RSS campaign from sending
        # @param [String] cid the id of the campaign to pause
        # @return [Hash] with a single entry:
        #     - [Bool] complete whether the call worked. reallistically this will always be true as errors will be thrown otherwise.
        def pause(cid)
            _params = {:cid => cid}
            return @master.call 'campaigns/pause', _params
        end

        # Returns information on whether a campaign is ready to send and possible issues we may have detected with it - very similar to the confirmation step in the app.
        # @param [String] cid the Campaign Id to replicate
        # @return [Hash] containing:
        #     - [Bool] is_ready whether or not you're going to be able to send this campaign
        #     - [Array] items an array of structs explaining basically what the app's confirmation step would
        #         - [String] type the item type - generally success, warning, or error
        #         - [String] heading the item's heading in the app
        #         - [String] details the item's details from the app, sans any html tags/links
        def ready(cid)
            _params = {:cid => cid}
            return @master.call 'campaigns/ready', _params
        end

        # Replicate a campaign.
        # @param [String] cid the Campaign Id to replicate
        # @return [Hash] the matching campaign's details - will return same data as single campaign from campaigns/list()
        def replicate(cid)
            _params = {:cid => cid}
            return @master.call 'campaigns/replicate', _params
        end

        # Resume sending an AutoResponder or RSS campaign
        # @param [String] cid the id of the campaign to pause
        # @return [Hash] with a single entry:
        #     - [Bool] complete whether the call worked. reallistically this will always be true as errors will be thrown otherwise.
        def resume(cid)
            _params = {:cid => cid}
            return @master.call 'campaigns/resume', _params
        end

        # Schedule a campaign to be sent in the future
        # @param [String] cid the id of the campaign to schedule
        # @param [String] schedule_time the time to schedule the campaign. For A/B Split "schedule" campaigns, the time for Group A - 24 hour format in <strong>GMT</strong>, eg "2013-12-30 20:30:00"
        # @param [String] schedule_time_b optional -the time to schedule Group B of an A/B Split "schedule" campaign  - 24 hour format in <strong>GMT</strong>, eg "2013-12-30 20:30:00"
        # @return [Hash] with a single entry:
        #     - [Bool] complete whether the call worked. reallistically this will always be true as errors will be thrown otherwise.
        def schedule(cid, schedule_time, schedule_time_b=nil)
            _params = {:cid => cid, :schedule_time => schedule_time, :schedule_time_b => schedule_time_b}
            return @master.call 'campaigns/schedule', _params
        end

        # Schedule a campaign to be sent in batches sometime in the future. Only valid for "regular" campaigns
        # @param [String] cid the id of the campaign to schedule
        # @param [String] schedule_time the time to schedule the campaign.
        # @param [Int] num_batches optional - the number of batches between 2 and 26 to send. defaults to 2
        # @param [Int] stagger_mins optional - the number of minutes between each batch - 5, 10, 15, 20, 25, 30, or 60. defaults to 5
        # @return [Hash] with a single entry:
        #     - [Bool] complete whether the call worked. reallistically this will always be true as errors will be thrown otherwise.
        def schedule_batch(cid, schedule_time, num_batches=2, stagger_mins=5)
            _params = {:cid => cid, :schedule_time => schedule_time, :num_batches => num_batches, :stagger_mins => stagger_mins}
            return @master.call 'campaigns/schedule-batch', _params
        end

        # Allows one to test their segmentation rules before creating a campaign using them
        # @param [String] list_id the list to test segmentation on - get lists using lists/list()
        # @param [Hash] options with 1 or 2 keys:
        #     - [String] saved_segment_id a saved segment id from lists/segments() - this will take precendence, otherwise the match+conditions are required.
        #     - [String] match controls whether to use AND or OR when applying your options - expects "<strong>any</strong>" (for OR) or "<strong>all</strong>" (for AND)
        #     - [Array] conditions of up to 5 structs for different criteria to apply while segmenting. Each criteria row must contain 3 keys - "<strong>field</strong>", "<strong>op</strong>", and "<strong>value</strong>" - and possibly a fourth, "<strong>extra</strong>", based on these definitions:
        # @return [Hash] with a single entry:
        #     - [Int] total The total number of subscribers matching your segmentation options
        def segment_test(list_id, options)
            _params = {:list_id => list_id, :options => options}
            return @master.call 'campaigns/segment-test', _params
        end

        # Send a given campaign immediately. For RSS campaigns, this will "start" them.
        # @param [String] cid the id of the campaign to send
        # @return [Hash] with a single entry:
        #     - [Bool] complete whether the call worked. reallistically this will always be true as errors will be thrown otherwise.
        def send(cid)
            _params = {:cid => cid}
            return @master.call 'campaigns/send', _params
        end

        # Send a test of this campaign to the provided email addresses
        # @param [String] cid the id of the campaign to test
        # @param [Array] test_emails an array of email address to receive the test message
        # @param [String] send_type by default just html is sent - can be "html" or "text" send specify the format
        # @return [Hash] with a single entry:
        #     - [Bool] complete whether the call worked. reallistically this will always be true as errors will be thrown otherwise.
        def send_test(cid, test_emails=[], send_type='html')
            _params = {:cid => cid, :test_emails => test_emails, :send_type => send_type}
            return @master.call 'campaigns/send-test', _params
        end

        # Get the HTML template content sections for a campaign. Note that this <strong>will</strong> return very jagged, non-standard results based on the template a campaign is using. You only want to use this if you want to allow editing template sections in your application.
        # @param [String] cid the campaign id to get content for (can be gathered using campaigns/list())
        # @return [Hash] content containing all content section for the campaign - section name are dependent upon the template used and thus can't be documented
        def template_content(cid)
            _params = {:cid => cid}
            return @master.call 'campaigns/template-content', _params
        end

        # Unschedule a campaign that is scheduled to be sent in the future
        # @param [String] cid the id of the campaign to unschedule
        # @return [Hash] with a single entry:
        #     - [Bool] complete whether the call worked. reallistically this will always be true as errors will be thrown otherwise.
        def unschedule(cid)
            _params = {:cid => cid}
            return @master.call 'campaigns/unschedule', _params
        end

        # Update just about any setting besides type for a campaign that has <em>not</em> been sent. See campaigns/create() for details. Caveats:<br/><ul class='bullets'> <li>If you set a new list_id, all segmentation options will be deleted and must be re-added.</li> <li>If you set template_id, you need to follow that up by setting it's 'content'</li> <li>If you set segment_opts, you should have tested your options against campaigns/segment-test().</li> <li>To clear/unset segment_opts, pass an empty string or array as the value. Various wrappers may require one or the other.</li> </ul>
        # @param [String] cid the Campaign Id to update
        # @param [String] name the parameter name ( see campaigns/create() ). This will be that parameter name (options, content, segment_opts) except "type_opts", which will be the name of the type - rss, auto, etc. The campaign "type" can not be changed.
        # @param [Array] value an appropriate set of values for the parameter ( see campaigns/create() ). For additional parameters, this is the same value passed to them.
        # @return [Hash] updated campaign details and any errors
        #     - [Hash] data the update campaign details - will return same data as single campaign from campaigns/list()
        #     - [Array] errors for "options" only - structs containing:
        #         - [Int] code the error code
        #         - [String] message the full error message
        #         - [String] name the parameter name that failed
        def update(cid, name, value)
            _params = {:cid => cid, :name => name, :value => value}
            return @master.call 'campaigns/update', _params
        end

    end
    class Vip
        attr_accessor :master

        def initialize(master)
            @master = master
        end

        # Retrieve all Activity (opens/clicks) for VIPs over the past 10 days
        # @return [Array] structs for each activity recorded.
        #     - [String] action The action taken - either "open" or "click"
        #     - [String] timestamp The datetime the action occurred in GMT
        #     - [String] url IF the action is a click, the url that was clicked
        #     - [String] unique_id The campaign_id of the List the Member appears on
        #     - [String] title The campaign title
        #     - [String] list_name The name of the List the Member appears on
        #     - [String] list_id The id of the List the Member appears on
        #     - [String] email The email address of the member
        #     - [String] fname IF a FNAME merge field exists on the list, that value for the member
        #     - [String] lname IF a LNAME merge field exists on the list, that value for the member
        #     - [Int] member_rating the rating of the subscriber. This will be 1 - 5 as described <a href="http://eepurl.com/f-2P" target="_blank">here</a>
        #     - [String] member_since the datetime the member was added and/or confirmed
        #     - [Hash] geo the geographic information if we have it. including:
        #         - [String] latitude the latitude
        #         - [String] longitude the longitude
        #         - [String] gmtoff GMT offset
        #         - [String] dstoff GMT offset during daylight savings (if DST not observered, will be same as gmtoff
        #         - [String] timezone the timezone we've place them in
        #         - [String] cc 2 digit ISO-3166 country code
        #         - [String] region generally state, province, or similar
        def activity()
            _params = {}
            return @master.call 'vip/activity', _params
        end

        # Add VIPs (previously called Golden Monkeys)
        # @param [String] id the list id to connect to. Get by calling lists/list()
        # @param [Array] emails an array of up to 50 email address structs to add, each with with one of the following keys
        #     - [String] email an email address - for new subscribers obviously this should be used
        #     - [String] euid the unique id for an email address (not list related) - the email "id" returned from listMemberInfo, Webhooks, Campaigns, etc.
        #     - [String] leid the list email id (previously called web_id) for a list-member-info type call. this doesn't change when the email address changes
        # @return [Hash] of data and success/error counts
        #     - [Int] success_count the number of successful adds
        #     - [Int] error_count the number of unsuccessful adds
        #     - [Array] errors array of error structs including:
        #         - [Hash] email whatever was passed in the email parameter
        #             - [String] email the email address added
        #             - [String] euid the email unique id
        #             - [String] leid the list member's truly unique id
        #         - [String] code the error code
        #         - [String] error the error message
        #     - [Array] data array of structs for each member added
        #         - [Hash] email whatever was passed in the email parameter
        #             - [String] email the email address added
        #             - [String] euid the email unique id
        #             - [String] leid the list member's truly unique id
        def add(id, emails)
            _params = {:id => id, :emails => emails}
            return @master.call 'vip/add', _params
        end

        # Remove VIPs - this does not affect list membership
        # @param [String] id the list id to connect to. Get by calling lists/list()
        # @param [Array] emails an array of up to 50 email address structs to remove, each with with one of the following keys
        #     - [String] email an email address - for new subscribers obviously this should be used
        #     - [String] euid the unique id for an email address (not list related) - the email "id" returned from listMemberInfo, Webhooks, Campaigns, etc.
        #     - [String] leid the list email id (previously called web_id) for a list-member-info type call. this doesn't change when the email address changes
        # @return [Hash] of data and success/error counts
        #     - [Int] success_count the number of successful deletions
        #     - [Int] error_count the number of unsuccessful deletions
        #     - [Array] errors array of error structs including:
        #         - [Hash] email whatever was passed in the email parameter
        #             - [String] email the email address
        #             - [String] euid the email unique id
        #             - [String] leid the list member's truly unique id
        #         - [String] code the error code
        #         - [String] msg the error message
        #     - [Array] data array of structs for each member deleted
        #         - [Hash] email whatever was passed in the email parameter
        #             - [String] email the email address
        #             - [String] euid the email unique id
        #             - [String] leid the list member's truly unique id
        def del(id, emails)
            _params = {:id => id, :emails => emails}
            return @master.call 'vip/del', _params
        end

        # Retrieve all Golden Monkey(s) for an account
        # @return [Array] structs for each Golden Monkey, including:
        #     - [String] list_id The id of the List the Member appears on
        #     - [String] list_name The name of the List the Member appears on
        #     - [String] email The email address of the member
        #     - [String] fname IF a FNAME merge field exists on the list, that value for the member
        #     - [String] lname IF a LNAME merge field exists on the list, that value for the member
        #     - [Int] member_rating the rating of the subscriber. This will be 1 - 5 as described <a href="http://eepurl.com/f-2P" target="_blank">here</a>
        #     - [String] member_since the datetime the member was added and/or confirmed
        def members()
            _params = {}
            return @master.call 'vip/members', _params
        end

    end
    class Reports
        attr_accessor :master

        def initialize(master)
            @master = master
        end

        # Get all email addresses that complained about a given campaign
        # @param [String] cid the campaign id to pull abuse reports for (can be gathered using campaigns/list())
        # @param [Hash] opts various options for controlling returned data
        #     - [Int] start optional for large data sets, the page number to start at - defaults to 1st page of data  (page 0)
        #     - [Int] limit optional for large data sets, the number of results to return - defaults to 25, upper limit set at 100
        #     - [String] since optional pull only messages since this time - 24 hour format in <strong>GMT</strong>, eg "2013-12-30 20:30:00"
        # @return [Hash] abuse report data for this campaign
        #     - [Int] total the total reports matched
        #     - [Array] data a struct for the each report, including:
        #         - [String] date date/time the abuse report was received and processed
        #         - [String] member the email address that reported abuse - will only contain email if the list or member has been removed
        #         - [String] type an internal type generally specifying the originating mail provider - may not be useful outside of filling report views
        def abuse(cid, opts=[])
            _params = {:cid => cid, :opts => opts}
            return @master.call 'reports/abuse', _params
        end

        # Retrieve the text presented in our app for how a campaign performed and any advice we may have for you - best suited for display in customized reports pages. Note: some messages will contain HTML - clean tags as necessary
        # @param [String] cid the campaign id to pull advice text for (can be gathered using campaigns/list())
        # @return [Array] of structs for advice on the campaign's performance, each containing:
        #     - [String] msg the advice message
        #     - [String] type the "type" of the message. one of: negative, positive, or neutral
        def advice(cid)
            _params = {:cid => cid}
            return @master.call 'reports/advice', _params
        end

        # Retrieve the most recent full bounce message for a specific email address on the given campaign. Messages over 30 days old are subject to being removed
        # @param [String] cid the campaign id to pull bounces for (can be gathered using campaigns/list())
        # @param [Hash] email a struct with one of the following keys - failing to provide anything will produce an error relating to the email address. Providing multiples and will use the first we see in this same order.
        #     - [String] email an email address - this is recommended for this method
        #     - [String] euid the unique id for an email address (not list related) - the email "id" returned from listMemberInfo, Webhooks, Campaigns, etc.
        #     - [String] leid the list email id (previously called web_id) for a list-member-info type call. this doesn't change when the email address changes
        # @return [Hash] the full bounce message for this email+campaign along with some extra data.
        #     - [String] date date the bounce was received and processed
        #     - [Hash] member the member record as returned by lists/member-info()
        #     - [String] message the entire bounce message received
        def bounce_message(cid, email)
            _params = {:cid => cid, :email => email}
            return @master.call 'reports/bounce-message', _params
        end

        # Retrieve the full bounce messages for the given campaign. Note that this can return very large amounts of data depending on how large the campaign was and how much cruft the bounce provider returned. Also, messages over 30 days old are subject to being removed
        # @param [String] cid the campaign id to pull bounces for (can be gathered using campaigns/list())
        # @param [Hash] opts various options for controlling returned data
        #     - [Int] start optional for large data sets, the page number to start at - defaults to 1st page of data  (page 0)
        #     - [Int] limit optional for large data sets, the number of results to return - defaults to 25, upper limit set at 100
        #     - [String] since optional pull only messages since this time - 24 hour format in <strong>GMT</strong>, eg "2013-12-30 20:30:00"
        # @return [Hash] data for the full bounce messages for this campaign
        #     - [Int] total that total number of bounce messages for the campaign
        #     - [Array] data structs containing the data for this page
        #         - [String] date date the bounce was received and processed
        #         - [Hash] member the member record as returned by lists/member-info()
        #         - [String] message the entire bounce message received
        def bounce_messages(cid, opts=[])
            _params = {:cid => cid, :opts => opts}
            return @master.call 'reports/bounce-messages', _params
        end

        # Return the list of email addresses that clicked on a given url, and how many times they clicked
        # @param [String] cid the campaign id to get click stats for (can be gathered using campaigns/list())
        # @param [Int] tid the "tid" for the URL from reports/clicks
        # @param [Hash] opts various options for controlling returned data
        #     - [Int] start optional for large data sets, the page number to start at - defaults to 1st page of data  (page 0)
        #     - [Int] limit optional for large data sets, the number of results to return - defaults to 25, upper limit set at 100
        #     - [String] sort_field optional the data to sort by - "clicked" (order clicks occurred, default) or "clicks" (total number of opens). Invalid fields will fall back on the default.
        #     - [String] sort_dir optional the direct - ASC or DESC. defaults to ASC (case insensitive)
        # @return [Hash] containing the total records matched and the specific records for this page
        #     - [Int] total the total number of records matched
        #     - [Array] data structs for each email addresses that click the requested url
        #         - [Hash] member the member record as returned by lists/member-info()
        #         - [Int] clicks Total number of times the URL was clicked by this email address
        def click_detail(cid, tid, opts=[])
            _params = {:cid => cid, :tid => tid, :opts => opts}
            return @master.call 'reports/click-detail', _params
        end

        # The urls tracked and their click counts for a given campaign.
        # @param [String] cid the campaign id to pull stats for (can be gathered using campaigns/list())
        # @return [Hash] including:
        #     - [Array] total structs for each url tracked for the full campaign
        #         - [String] url the url being tracked - urls are tracked individually, so duplicates can exist with vastly different stats
        #         - [Int] clicks Number of times the specific link was clicked
        #         - [Double] clicks_percent the percentage of total clicks "clicks" represents
        #         - [Int] unique Number of unique people who clicked on the specific link
        #         - [Double] unique_percent the percentage of unique clicks "unique" represents
        #         - [Int] tid the tracking id used in campaign links - used primarily for reports/click-activity. also can be used to order urls by the order they appeared in the campaign to recreate our heat map.
        #     - [Array] a if this was an absplit campaign, stat structs for the a group
        #         - [String] url the url being tracked - urls are tracked individually, so duplicates can exist with vastly different stats
        #         - [Int] clicks Number of times the specific link was clicked
        #         - [Double] clicks_percent the percentage of total clicks "clicks" represents
        #         - [Int] unique Number of unique people who clicked on the specific link
        #         - [Double] unique_percent the percentage of unique clicks "unique" represents
        #         - [Int] tid the tracking id used in campaign links - used primarily for reports/click-activity. also can be used to order urls by the order they appeared in the campaign to recreate our heat map.
        #     - [Array] b if this was an absplit campaign, stat structs for the b group
        #         - [String] url the url being tracked - urls are tracked individually, so duplicates can exist with vastly different stats
        #         - [Int] clicks Number of times the specific link was clicked
        #         - [Double] clicks_percent the percentage of total clicks "clicks" represents
        #         - [Int] unique Number of unique people who clicked on the specific link
        #         - [Double] unique_percent the percentage of unique clicks "unique" represents
        #         - [Int] tid the tracking id used in campaign links - used primarily for reports/click-activity. also can be used to order urls by the order they appeared in the campaign to recreate our heat map.
        def clicks(cid)
            _params = {:cid => cid}
            return @master.call 'reports/clicks', _params
        end

        # Retrieve the Ecommerce Orders tracked by ecomm/order-add()
        # @param [String] cid the campaign id to pull orders for for (can be gathered using campaigns/list())
        # @param [Hash] opts various options for controlling returned data
        #     - [Int] start optional for large data sets, the page number to start at - defaults to 1st page of data  (page 0)
        #     - [Int] limit optional for large data sets, the number of results to return - defaults to 25, upper limit set at 100
        #     - [String] since optional pull only messages since this time - 24 hour format in <strong>GMT</strong>, eg "2013-12-30 20:30:00"
        # @return [Hash] the total matching orders and the specific orders for the requested page
        #     - [Int] total the total matching orders
        #     - [Array] data structs for the actual data for each order being returned
        #     - [String] store_id the store id generated by the plugin used to uniquely identify a store
        #     - [String] store_name the store name collected by the plugin - often the domain name
        #     - [String] order_id the internal order id the store tracked this order by
        #     - [Hash] member the member record as returned by lists/member-info() that received this campaign and is associated with this order
        #     - [Double] order_total the order total
        #     - [Double] tax_total the total tax for the order (if collected)
        #     - [Double] ship_total the shipping total for the order (if collected)
        #     - [String] order_date the date the order was tracked - from the store if possible, otherwise the GMT time we received it
        #     - [Array] lines structs containing details of the order:
        #         - [Int] line_num the line number assigned to this line
        #         - [Int] product_id the product id assigned to this item
        #         - [String] product_name the product name
        #         - [String] product_sku the sku for the product
        #         - [Int] product_category_id the id for the product category
        #         - [String] product_category_name the product category name
        #         - [Double] qty optional the quantity of the item ordered - defaults to 1
        #         - [Double] cost optional the cost of a single item (ie, not the extended cost of the line) - defaults to 0
        def ecomm_orders(cid, opts=[])
            _params = {:cid => cid, :opts => opts}
            return @master.call 'reports/ecomm-orders', _params
        end

        # Retrieve the eepurl stats from the web/Twitter mentions for this campaign
        # @param [String] cid the campaign id to pull stats for (can be gathered using campaigns/list())
        # @return [Hash] containing tweets, retweets, clicks, and referrer related to using the campaign's eepurl
        #     - [Hash] twitter various Twitter related stats
        #         - [Int] tweets Total number of tweets seen
        #         - [String] first_tweet date and time of the first tweet seen
        #         - [String] last_tweet date and time of the last tweet seen
        #         - [Int] retweets Total number of retweets seen
        #         - [String] first_retweet date and time of the first retweet seen
        #         - [String] last_retweet date and time of the last retweet seen
        #         - [Array] statuses an structs for statuses recorded including:
        #             - [String] status the text of the tweet/update
        #             - [String] screen_name the screen name as recorded when first seen
        #             - [String] status_id the status id of the tweet (they are really unsigned 64 bit ints)
        #             - [String] datetime the date/time of the tweet
        #             - [Bool] is_retweet whether or not this was a retweet
        #     - [Hash] clicks stats related to click-throughs on the eepurl
        #         - [Int] clicks Total number of clicks seen
        #         - [String] first_click date and time of the first click seen
        #         - [String] last_click date and time of the first click seen
        #         - [Array] locations structs for geographic locations including:
        #             - [String] country the country name the click was tracked to
        #             - [String] region the region in the country the click was tracked to (if available)
        #     - [Array] referrers structs for referrers, including
        #         - [String] referrer the referrer, truncated to 100 bytes
        #         - [Int] clicks Total number of clicks seen from this referrer
        #         - [String] first_click date and time of the first click seen from this referrer
        #         - [String] last_click date and time of the first click seen from this referrer
        def eepurl(cid)
            _params = {:cid => cid}
            return @master.call 'reports/eepurl', _params
        end

        # Given a campaign and email address, return the entire click and open history with timestamps, ordered by time. If you need to dump the full activity for a campaign and/or get incremental results, you should use the <a href="http://apidocs.mailchimp.com/export/1.0/campaignsubscriberactivity.func.php" targret="_new">campaignSubscriberActivity Export API method</a>, <strong>not</strong> this, especially for large campaigns.
        # @param [String] cid the campaign id to get stats for (can be gathered using campaigns/list())
        # @param [Array] emails an array of up to 50 email address struct to retrieve activity information for
        #     - [String] email an email address
        #     - [String] euid the unique id for an email address (not list related) - the email "id" returned from listMemberInfo, Webhooks, Campaigns, etc.
        #     - [String] leid the list email id (previously called web_id) for a list-member-info type call. this doesn't change when the email address changes
        # @return [Hash] of data and success/error counts
        #     - [Int] success_count the number of subscribers successfully found on the list
        #     - [Int] error_count the number of subscribers who were not found on the list
        #     - [Array] errors array of error structs including:
        #         - [String] email whatever was passed in the email parameter
        #             - [String] email the email address added
        #             - [String] euid the email unique id
        #             - [String] leid the list member's truly unique id
        #         - [String] msg the error message
        #     - [Array] data an array of structs where each activity record has:
        #         - [String] email whatever was passed in the email parameter
        #             - [String] email the email address added
        #             - [String] euid the email unique id
        #             - [String] leid the list member's truly unique id
        #         - [Hash] member the member record as returned by lists/member-info()
        #         - [Array] activity an array of structs containing the activity, including:
        #             - [String] action The action name - either open or click
        #             - [String] timestamp The date/time of the action (GMT)
        #             - [String] url For click actions, the url clicked, otherwise this is empty
        #             - [String] ip The IP address the activity came from
        def member_activity(cid, emails)
            _params = {:cid => cid, :emails => emails}
            return @master.call 'reports/member-activity', _params
        end

        # Retrieve the list of email addresses that did not open a given campaign
        # @param [String] cid the campaign id to get no opens for (can be gathered using campaigns/list())
        # @param [Hash] opts various options for controlling returned data
        #     - [Int] start optional for large data sets, the page number to start at - defaults to 1st page of data  (page 0)
        #     - [Int] limit optional for large data sets, the number of results to return - defaults to 25, upper limit set at 100
        # @return [Hash] a total of all matching emails and the specific emails for this page
        #     - [Int] total the total number of members who didn't open the campaign
        #     - [Array] data structs for each campaign member matching as returned by lists/member-info()
        def not_opened(cid, opts=[])
            _params = {:cid => cid, :opts => opts}
            return @master.call 'reports/not-opened', _params
        end

        # Retrieve the list of email addresses that opened a given campaign with how many times they opened
        # @param [String] cid the campaign id to get opens for (can be gathered using campaigns/list())
        # @param [Hash] opts various options for controlling returned data
        #     - [Int] start optional for large data sets, the page number to start at - defaults to 1st page of data  (page 0)
        #     - [Int] limit optional for large data sets, the number of results to return - defaults to 25, upper limit set at 100
        #     - [String] sort_field optional the data to sort by - "opened" (order opens occurred, default) or "opens" (total number of opens). Invalid fields will fall back on the default.
        #     - [String] sort_dir optional the direct - ASC or DESC. defaults to ASC (case insensitive)
        # @return [Hash] containing the total records matched and the specific records for this page
        #     - [Int] total the total number of records matched
        #     - [Array] data structs for the actual opens data, including:
        #         - [Hash] member the member record as returned by lists/member-info()
        #         - [Int] opens Total number of times the campaign was opened by this email address
        def opened(cid, opts=[])
            _params = {:cid => cid, :opts => opts}
            return @master.call 'reports/opened', _params
        end

        # Get the top 5 performing email domains for this campaign. Users wanting more than 5 should use campaign reports/member-activity() or campaignEmailStatsAIMAll() and generate any additional stats they require.
        # @param [String] cid the campaign id to pull email domain performance for (can be gathered using campaigns/list())
        # @return [Array] domains structs for each email domains and their associated stats
        #     - [String] domain Domain name or special "Other" to roll-up stats past 5 domains
        #     - [Int] total_sent Total Email across all domains - this will be the same in every row
        #     - [Int] emails Number of emails sent to this domain
        #     - [Int] bounces Number of bounces
        #     - [Int] opens Number of opens
        #     - [Int] clicks Number of clicks
        #     - [Int] unsubs Number of unsubs
        #     - [Int] delivered Number of deliveries
        #     - [Int] emails_pct Percentage of emails that went to this domain (whole number)
        #     - [Int] bounces_pct Percentage of bounces from this domain (whole number)
        #     - [Int] opens_pct Percentage of opens from this domain (whole number)
        #     - [Int] clicks_pct Percentage of clicks from this domain (whole number)
        #     - [Int] unsubs_pct Percentage of unsubs from this domain (whole number)
        def domain_performance(cid)
            _params = {:cid => cid}
            return @master.call 'reports/domain-performance', _params
        end

        # Retrieve the countries/regions and number of opens tracked for each. Email address are not returned.
        # @param [String] cid the campaign id to pull bounces for (can be gathered using campaigns/list())
        # @return [Array] an array of country structs where opens occurred
        #     - [String] code The ISO3166 2 digit country code
        #     - [String] name A version of the country name, if we have it
        #     - [Int] opens The total number of opens that occurred in the country
        #     - [Array] regions structs of data for each sub-region in the country
        #         - [String] code An internal code for the region. When this is blank, it indicates we know the country, but not the region
        #         - [String] name The name of the region, if we have one. For blank "code" values, this will be "Rest of Country"
        #         - [Int] opens The total number of opens that occurred in the country
        def geo_opens(cid)
            _params = {:cid => cid}
            return @master.call 'reports/geo-opens', _params
        end

        # Retrieve the Google Analytics data we've collected for this campaign. Note, requires Google Analytics Add-on to be installed and configured.
        # @param [String] cid the campaign id to pull bounces for (can be gathered using campaigns/list())
        # @return [Array] of structs for analytics we've collected for the passed campaign.
        #     - [Int] visits number of visits
        #     - [Int] pages number of page views
        #     - [Int] new_visits new visits recorded
        #     - [Int] bounces vistors who "bounced" from your site
        #     - [Double] time_on_site the total time visitors spent on your sites
        #     - [Int] goal_conversions number of goals converted
        #     - [Double] goal_value value of conversion in dollars
        #     - [Double] revenue revenue generated by campaign
        #     - [Int] transactions number of transactions tracked
        #     - [Int] ecomm_conversions number Ecommerce transactions tracked
        #     - [Array] goals structs containing goal names and number of conversions
        #         - [String] name the name of the goal
        #         - [Int] conversions the number of conversions for the goal
        def google_analytics(cid)
            _params = {:cid => cid}
            return @master.call 'reports/google-analytics', _params
        end

        # Get email addresses the campaign was sent to
        # @param [String] cid the campaign id to pull members for (can be gathered using campaigns/list())
        # @param [Hash] opts various options for controlling returned data
        #     - [String] status optional the status to pull - one of 'sent', 'hard' (bounce), or 'soft' (bounce). By default, all records are returned
        #     - [Int] start optional for large data sets, the page number to start at - defaults to 1st page of data  (page 0)
        #     - [Int] limit optional for large data sets, the number of results to return - defaults to 25, upper limit set at 100
        # @return [Hash] a total of all matching emails and the specific emails for this page
        #     - [Int] total the total number of members for the campaign and status
        #     - [Array] data structs for each campaign member matching
        #         - [Hash] member the member record as returned by lists/member-info()
        #         - [String] status the status of the send - one of 'sent', 'hard', 'soft'
        #         - [String] absplit_group if this was an absplit campaign, one of 'a','b', or 'winner'
        #         - [String] tz_group if this was an timewarp campaign the timezone GMT offset the member was included in
        def sent_to(cid, opts=[])
            _params = {:cid => cid, :opts => opts}
            return @master.call 'reports/sent-to', _params
        end

        # Get the URL to a customized <a href="http://eepurl.com/gKmL" target="_blank">VIP Report</a> for the specified campaign and optionally send an email to someone with links to it. Note subsequent calls will overwrite anything already set for the same campign (eg, the password)
        # @param [String] cid the campaign id to share a report for (can be gathered using campaigns/list())
        # @param [Array] opts optional various parameters which can be used to configure the shared report
        #     - [String] to_email optional - optional, comma delimited list of email addresses to share the report with - no value means an email will not be sent
        #     - [Int] theme_id optional - either a global or a user-specific theme id. Currently this needs to be pulled out of either the Share Report or Cobranding web views by grabbing the "theme" attribute from the list presented.
        #     - [String] css_url optional - a link to an external CSS file to be included after our default CSS (http://vip-reports.net/css/vip.css) <strong>only if</strong> loaded via the "secure_url" - max 255 bytes
        # @return [Hash] details for the shared report, including:
        #     - [String] title The Title of the Campaign being shared
        #     - [String] url The URL to the shared report
        #     - [String] secure_url The URL to the shared report, including the password (good for loading in an IFRAME). For non-secure reports, this will not be returned
        #     - [String] password If secured, the password for the report, otherwise this field will not be returned
        def share(cid, opts=[])
            _params = {:cid => cid, :opts => opts}
            return @master.call 'reports/share', _params
        end

        # Retrieve relevant aggregate campaign statistics (opens, bounces, clicks, etc.)
        # @param [String] cid the campaign id to pull stats for (can be gathered using campaigns/list())
        # @return [Hash] the statistics for this campaign
        #     - [Int] syntax_errors Number of email addresses in campaign that had syntactical errors.
        #     - [Int] hard_bounces Number of email addresses in campaign that hard bounced.
        #     - [Int] soft_bounces Number of email addresses in campaign that soft bounced.
        #     - [Int] unsubscribes Number of email addresses in campaign that unsubscribed.
        #     - [Int] abuse_reports Number of email addresses in campaign that reported campaign for abuse.
        #     - [Int] forwards Number of times email was forwarded to a friend.
        #     - [Int] forwards_opens Number of times a forwarded email was opened.
        #     - [Int] opens Number of times the campaign was opened.
        #     - [String] last_open Date of the last time the email was opened.
        #     - [Int] unique_opens Number of people who opened the campaign.
        #     - [Int] clicks Number of times a link in the campaign was clicked.
        #     - [Int] unique_clicks Number of unique recipient/click pairs for the campaign.
        #     - [String] last_click Date of the last time a link in the email was clicked.
        #     - [Int] users_who_clicked Number of unique recipients who clicked on a link in the campaign.
        #     - [Int] emails_sent Number of email addresses campaign was sent to.
        #     - [Int] unique_likes total number of unique likes (Facebook)
        #     - [Int] recipient_likes total number of recipients who liked (Facebook) the campaign
        #     - [Int] facebook_likes total number of likes (Facebook) that came from Facebook
        #     - [Hash] industry Various rates/percentages for the account's selected industry - empty otherwise. These will vary across calls, do not use them for anything important.
        #         - [String] type the selected industry
        #         - [Float] open_rate industry open rate
        #         - [Float] click_rate industry click rate
        #         - [Float] bounce_rate industry bounce rate
        #         - [Float] unopen_rate industry unopen rate
        #         - [Float] unsub_rate industry unsub rate
        #         - [Float] abuse_rate industry abuse rate
        #     - [Hash] absplit If this was an absplit campaign, stats for the A and B groups will be returned - otherwise this is empty
        #         - [Int] bounces_a bounces for the A group
        #         - [Int] bounces_b bounces for the B group
        #         - [Int] forwards_a forwards for the A group
        #         - [Int] forwards_b forwards for the B group
        #         - [Int] abuse_reports_a abuse reports for the A group
        #         - [Int] abuse_reports_b abuse reports for the B group
        #         - [Int] unsubs_a unsubs for the A group
        #         - [Int] unsubs_b unsubs for the B group
        #         - [Int] recipients_click_a clicks for the A group
        #         - [Int] recipients_click_b clicks for the B group
        #         - [Int] forwards_opens_a opened forwards for the A group
        #         - [Int] forwards_opens_b opened forwards for the B group
        #         - [Int] opens_a total opens for the A group
        #         - [Int] opens_b total opens for the B group
        #         - [String] last_open_a date/time of last open for the A group
        #         - [String] last_open_b date/time of last open for the BG group
        #         - [Int] unique_opens_a unique opens for the A group
        #         - [Int] unique_opens_b unique opens for the B group
        #     - [Array] timewarp If this campaign was a Timewarp campaign, an array of structs from each timezone stats exist for. Each will contain:
        #         - [Int] opens opens for this timezone
        #         - [String] last_open the date/time of the last open for this timezone
        #         - [Int] unique_opens the unique opens for this timezone
        #         - [Int] clicks the total clicks for this timezone
        #         - [String] last_click the date/time of the last click for this timezone
        #         - [Int] unique_opens the unique clicks for this timezone
        #         - [Int] bounces the total bounces for this timezone
        #         - [Int] total the total number of members sent to in this timezone
        #         - [Int] sent the total number of members delivered to in this timezone
        #     - [Array] timeseries structs for the first 24 hours of the campaign, per-hour stats:
        #         - [String] timestamp The timestemp in Y-m-d H:00:00 format
        #         - [Int] emails_sent the total emails sent during the hour
        #         - [Int] unique_opens unique opens seen during the hour
        #         - [Int] recipients_click unique clicks seen during the hour
        def summary(cid)
            _params = {:cid => cid}
            return @master.call 'reports/summary', _params
        end

        # Get all unsubscribed email addresses for a given campaign
        # @param [String] cid the campaign id to pull bounces for (can be gathered using campaigns/list())
        # @param [Hash] opts various options for controlling returned data
        #     - [Int] start optional for large data sets, the page number to start at - defaults to 1st page of data  (page 0)
        #     - [Int] limit optional for large data sets, the number of results to return - defaults to 25, upper limit set at 100
        # @return [Hash] a total of all unsubscribed emails and the specific members for this page
        #     - [Int] total the total number of unsubscribes for the campaign
        #     - [Array] data structs for the email addresses that unsubscribed
        #         - [String] member the member that unsubscribed as returned by lists/member-info()
        #         - [String] reason the reason collected for the unsubscribe. If populated, one of 'NORMAL','NOSIGNUP','INAPPROPRIATE','SPAM','OTHER'
        #         - [String] reason_text if the reason is OTHER, the text entered.
        def unsubscribes(cid, opts=[])
            _params = {:cid => cid, :opts => opts}
            return @master.call 'reports/unsubscribes', _params
        end

    end
    class Gallery
        attr_accessor :master

        def initialize(master)
            @master = master
        end

        # Return a section of the image gallery
        # @param [Hash] opts various options for controlling returned data
        #     - [String] type optional the gallery type to return - images or files - default to images
        #     - [Int] start optional for large data sets, the page number to start at - defaults to 1st page of data  (page 0)
        #     - [Int] limit optional for large data sets, the number of results to return - defaults to 25, upper limit set at 100
        #     - [String] sort_by optional field to sort by - one of size, time, name - defaults to time
        #     - [String] sort_dir optional field to sort by - one of asc, desc - defaults to desc
        #     - [String] search_term optional a term to search for in names
        # @return [Hash] the matching gallery items
        #     - [Int] total the total matching items
        #     - [Array] data structs for each item included in the set, including:
        #         - [String] name the file name
        #         - [String] time the creation date for the item
        #         - [Int] size the file size in bytes
        #         - [String] full the url to the actual item in the gallery
        #         - [String] thumb a url for a thumbnail that can be used to represent the item, generally an image thumbnail or an icon for a file type
        def list(opts=[])
            _params = {:opts => opts}
            return @master.call 'gallery/list', _params
        end

    end
end

