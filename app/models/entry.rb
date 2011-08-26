class Entry < ActiveRecord::Base
  belongs_to :source
  VALID_GROUPS = [:client_ip, :access_time, :duration, :http_request, :status_code, :referrer, :user_agent].freeze

  def parse_request!
    return unless http_request
    return unless http_request =~ /^(\S+)\s+(\S+)/
    self.http_method = Regexp.last_match(1).downcase
    self.http_url = Regexp.last_match 2
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

    groups.each_with_index do |group, index|
      next if group.blank?
      value = Regexp.last_match(index + 1)
      value = DateTime.strptime value, "%d/%b/%Y:%H:%M:%S %Z" if group == :access_time
      send "#{group}=", value
    end

    parse_request!
    self.parsed = true
    save!
  end

  class << self
    def histogram(options)
      options.date_ranges(100).map do |range|
        count :conditions => { :access_time => range }
      end
    end
  end
end
