class Entry < ActiveRecord::Base
  belongs_to :source
  VALID_GROUPS = [:client_ip, :access_time, :duration, :http_request, :status_code, :referrer, :user_agent, :server_name].freeze

  PARSED_COLUMNS = [:source_id, :original, :parsed, :server_name, :client_ip, :access_time, :duration, :http_request, :http_method, :http_url, :http_query_string, :status_code, :referrer, :user_agent, :user_agent_type, :created_at, :updated_at].freeze

  def parse!(regex, groups, options = {})
    return if parsed unless options[:force]
    parsed = Entry.parse! nil, original, regex, groups

    VALID_GROUPS.each do |group|
      send "#{group}=", nil
    end

    self.http_method = nil
    self.http_url = nil
    self.http_query_string = nil
    self.user_agent_type = nil

    parsed.each do |key, value|
      send "#{key}=", value
    end

    save!
  end

  class << self
    def average_duration_histogram(options)
      options.date_ranges.map do |range|
        Entry.where(:source_id => options.sources, :parsed => true, :access_time => range).average(:duration) || 0
      end
    end

    def max_duration_histogram(options)
      options.date_ranges.map do |range|
        Entry.where(:source_id => options.sources, :parsed => true, :access_time => range).maximum(:duration) || 0
      end
    end

    def request_histogram(options)
      options.date_ranges.map do |range|
        count :conditions => { :source_id => options.sources, :parsed => true, :access_time => range }
      end
    end

    def url_histogram(options)
      select([:http_url, "count(*) AS url_count"]).where(:source_id => options.sources, :parsed => true, :access_time => options.date_range).group(:http_url).order("url_count DESC").limit(250)
    end

    def parse!(source, line, regex, groups)
      groups.each do |group|
        next if group.blank?
        raise "Invalid group #{group}" unless VALID_GROUPS.include? group
      end

      result = { :original => line }
      result[:source_id] = source.id if source
      return result unless line =~ regex

      groups.each_with_index do |group, index|
        next if group.blank?
        value = Regexp.last_match(index + 1)
        result[group] = value
      end

      # parse request
      if result[:http_request] && result[:http_request] =~ /^(\S+)\s+(\S+?)(?:\?(\S+))?(?:\s|$)/
        result[:http_method] = Regexp.last_match(1).downcase
        result[:http_url] = Regexp.last_match 2
        result[:http_query_string] = Regexp.last_match 3
      end

      # parse user agent
      if result[:user_agent]
        ua = result[:user_agent].downcase

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

        result[:user_agent_type] = type || "Unknown"
      end

      result[:parsed] = true
      reify_types! result
      result
    end

    private
    def reify_types!(parsed)
      parsed[:access_time] = DateTime.strptime parsed[:access_time], "%d/%b/%Y:%H:%M:%S %Z" if parsed[:access_time]
      parsed[:duration] = parsed[:duration].to_f if parsed[:duration]
      parsed[:status_code] = parsed[:status_code].to_i if parsed[:status_code]
    end
  end
end
