# Methods added to this helper will be available to all templates in the application.
require 'fileutils'
module ApplicationHelper   
  # class CriticalAlertException < RuntimeError
  # end  

  include UtilityHelper
  include UserHelper
  #these are taken from cd /var/lib/pgsql/data/pg_hba.conf on dfw-web1
  #don't need this because we're filter on Google Analytics site (Edit Settings)
  #  @@google_analytics_filter = ["74.138.221.245", 
  #                               "24.214.236.100", 
  #                               "24.214.236.101", 
  #                               "24.214.110.48", 
  #                               "99.150.101.191", 
  #                               "68.174.89.40", 
  #                               "65.13.94.42"]
  #  
  def google_analytics_check    
    (request.host == 'myhalomonitor.com' or request.host == 'www.myhalomonitor.com') #and !@@google_analytics_filter.include? request.env["REMOTE_ADDR"].to_s
  end

  def image_for_event(event)
    type = event[:event_type]
    if ['Fall', 'Panic'].include? type
      return image_tag('/images/severe_button_82_22.png')
    elsif ['GatewayOfflineAlert', 'DeviceUnavailbleAlert', 'BatteryCritical','DialUpStatus','StrapRemoved'].include? type
      return image_tag('/images/caution_button_82_22.png')
    elsif ['BatteryReminder'].include? type and !event.event.nil?
      if event.event.reminder_num < 3
        return image_tag('/images/caution_button_82_22.png')
      elsif event.event.reminder_num == 3
        return image_tag('/images/severe_button_82_22.png')
      elsif event.event.reminder_num == 4
        return image_tag('/images/normal_button_82_22.png')
      end
    else 
      return image_tag('/images/normal_button_82_22.png')
    end
  end

  # reference from active_merchant code
  #
  # CARD_COMPANIES = { 
  #   'visa'               => /^4\d{12}(\d{3})?$/,
  #   'master'             => /^(5[1-5]\d{4}|677189)\d{10}$/,
  #   'discover'           => /^(6011|65\d{2})\d{12}$/,
  #   'american_express'   => /^3[47]\d{13}$/,
  #   'diners_club'        => /^3(0[0-5]|[68]\d)\d{11}$/,
  #   'jcb'                => /^35(28|29|[3-8]\d)\d{12}$/,
  #   'switch'             => /^6759\d{12}(\d{2,3})?$/,  
  #   'solo'               => /^6767\d{12}(\d{2,3})?$/,
  #   'dankort'            => /^5019\d{12}$/,
  #   'maestro'            => /^(5[06-8]|6\d)\d{10,17}$/,
  #   'forbrugsforeningen' => /^600722\d{10}$/,
  #   'laser'              => /^(6304|6706|6771|6709)\d{8}(\d{4}|\d{6,7})?$/
  # }
  def credit_card_types
    return {
      'VISA'              => 'visa',
      'MasterCard'        => 'master',
      'American Express'  => 'american_express',
      'Discover'          => 'discover'
    }
  end

  def USD_value(amount = 0)
    number_to_currency(amount, :precision => 2, :unit => "$", :delimiter => ",", :separator => ".")
  end

  # accepts the name of model as string, returns and constant for the model
  #   singular, plural, with or without underscore
  #   examples: user, book_store. book stores, account payables
  def model_name_to_constant(name)
    name = name.gsub(/_/,' ') if name =~ /_/ # convert <underscore> to <space>
    name.singularize.split(/ |_/).collect(&:capitalize).join.constantize
  end

  # CHANGED: obsolete method. Use File.makedirs("/path/to/dir") instead
  # just ensure the folder exists as specified in the full path
  # def ensure_folder(path)
  #   # paths = csv_to_array(path)
  #   # Dir.mkdir(path) unless File.exists?(path)
  # end

  def recursively_delete_dir(dir)
    FileUtils.rm_rf(dir) # or use FileUtils.rm_r(dir, :force => true)
    # system("rm -rf #{dir}")
  end

  # take a comma/<delimiter> separated string/text and return an array of strings.
  # no blank spaces before/after each element value
  def csv_to_array(phrase, delimiter = ',')
    phrase.split(delimiter).collect {|p| p.lstrip.rstrip }
  end

  # recursively find value in hash
  def recursively_search_hash(hash, key)
    values = hash.collect {|k, v| v if k == key}.compact
    values << hash.collect { |k, v| recursively_search_hash(v, key) if v.is_a?(Hash) }
    values << hash.collect do |k, v|
      v.collect {|element| recursively_search_hash(element, key) if element.is_a?(Hash) } if v.is_a?(Array)
    end
    return values.flatten.compact.uniq
  end

  def hash_to_html(hash)
    data = hash.collect {|k,v| v.is_a?(Hash) ? "<li>#{k}#{hash_to_html(v)}</li>" : "<li>#{k} => #{v}</li>"}
    "<ul>#{data}</ul>"
  end

  def yes_no_options_for_select
    [['Yes', '1'], ['No', '0']] # '1' and '0' will update boolean fields in tables
  end
  
  # config/environment.rb: config.gem "markaby"
  # usage:
  #   markaby do
  #   div.class_for_this_div do
  #     h2 "Header text"
  #     p "Content for paragraph"
  #     ul do
  #       li "first list item"
  #       li "another list item"
  #     end
  #   end
  # end
  def markaby(&block)
    Markaby::Builder.new({}, self, &block)
  end
  
  # this makes the following possible in views
  #   <% javascript 'some_js_file' %>
  # or
  #   <% javascript do %>
  #     <script src="/javascripts/application.js" type="text/javascript"></script>
  #     <%= javascript_include_tag "more_js", :cache => true %>
  #   <% end %>
  # or
  #   <% javascript do %>
  #     function check_it() { document.getElementById("element-id"); }
  #   <% end %>  
  def javascript(*file_names, &block)
    content_for(:js) { javascript_include_tag(*file_names) }
    if block_given?
      captured = capture(&block)
      if captured.include?("<script")
        content_for(:js) { concat( captured, block.binding) }
      else
        content_for(:js) do
          concat( "<script type=\"text/javascript\">", block.binding)
          concat( captured, block.binding)
          concat( "</script>", block.binding)
        end
      end
    end
  end

  # this makes the following possible in views
  #   <% stylesheet 'some_css_file' %>
  # or
  #   <% stylesheet do %>
  #     <link href="/stylesheets/layout.css" media="screen" rel="stylesheet" type="text/css" />
  #     <%= stylesheet_link_tag "another_css_file", :cache => true %>
  #   <% end %>
  # or
  #   <% stylesheet do %>
  #     a { color: #000; }
  #   <% end %>  
  def stylesheet(*file_names, &block)
    content_for(:css) { stylesheet_link_tag(*file_names) }
    if block_given?
      captured = capture(&block)
      if captured.include?("<style")
        content_for(:css) { concat( capture(&block), block.binding) }
      else
        content_for(:css) do
          concat( "<style type=\"text/css\" media=\"screen\">", block.binding)
          concat( captured, block.binding)
          concat( "</style>", block.binding)
        end
      end
    end
  end

  # this makes the following possible in views
  #   <% meta_tag "<meta http-equiv='Content-Type' content='text/html; charset=utf-8'>" %>
  # or
  #   <% meta_tag do %>
  #     <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
  #     <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
  #   <% end %>
  def meta_tag(*tags, &block)
    content_for(:meta_tags) { tags }
    content_for(:meta_tags) { concat(capture( &block), block.binding) if block_given? }
  end
end
