class Entry < ActiveRecord::Base
  belongs_to :source
  VALID_GROUPS = [:client_ip, :access_time, :duration, :http_request, :status_code, :referrer, :user_agent, :server_name].freeze

  def parse_request!
    return unless http_request
    return unless http_request =~ /^(\S+)\s+(\S+?)(?:\?(\S+))?(?:\s|$)/
    self.http_method = Regexp.last_match(1).downcase
    self.http_url = Regexp.last_match 2
    self.http_query_string = Regexp.last_match 3
  end

  def parse_user_agent!
    return unless user_agent
    ua = user_agent.downcase

    if ua.include?("msie") && ua.include?("chrome")
      type = "Internet Explorer (ChromeFrame)"
    elsif ua.include? "msie"
      type = "Internet Explorer"
    elsif ua.include? "firefox"
      type = "FireFox"
    elsif ua.include? "chrome"
      type = "Chrome"
    elsif ua.include? "blackberry"
      type = "Blackberry"
    elsif ua.include? "opera mini"
      type = "Opera Mini"
    elsif ua.include? "opera"
      type = "Opera"
    elsif ua.include?("android") && ua.include?("mobile") && ua.include?("safari")
      type = "Mobile Safari (Android)"
    elsif ua.include?("iphone") && ua.include?("mobile") && ua.include?("safari")
      type = "Mobile Safari (iPhone)"
    elsif ua.include?("ipad") && ua.include?("mobile") && ua.include?("safari")
      type = "Mobile Safari (iPad)"
    elsif ua.include?("mobile") && ua.include?("safari")
      type = "Mobile Safari (Other)"
    elsif ua.include? "safari"
      type = "Safari"
    elsif ua.include? "netscape"
      type = "Netscape"
    end

    self.user_agent_type = type || "Unknown"
  end

  def parse!(regex, groups, options = {})
    return if parsed unless options[:force]

    groups.each do |group|
      next if group.blank?
      raise "Invalid group #{group}" unless VALID_GROUPS.include? group
    end

    return unless original =~ regex

    VALID_GROUPS.each do |group|
      send "#{group}=", nil
    end

    self.http_method = nil
    self.http_url = nil
    self.http_query_string = nil
    self.user_agent_type = nil

    groups.each_with_index do |group, index|
      next if group.blank?
      value = Regexp.last_match(index + 1)
      value = DateTime.strptime value, "%d/%b/%Y:%H:%M:%S %Z" if group == :access_time
      send "#{group}=", value
    end

    parse_request!
    parse_user_agent!
    self.parsed = true
    save!
  end

  class << self
    def histogram(options)
      options.date_ranges.map do |range|
        count :conditions => { :source_id => options.sources, :parsed => true, :access_time => range }
      end
    end
  end
end
