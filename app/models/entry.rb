class Entry < ActiveRecord::Base
  belongs_to :source
  VALID_GROUPS = [:client_ip, :access_time, :duration, :http_request, :status_code, :referrer, :user_agent].freeze

  def parse!(regex, groups)
    return if parsed

    groups.each do |group|
      next if group.blank?
      raise "Invalid group #{group}" unless VALID_GROUPS.include? group.to_sym
    end

    return unless original =~ regex

    groups.each_with_index do |group, index|
      next if group.blank?
      send "#{group}=", Regexp.last_match(index + 1)
    end

    self.parsed = true
    save!
  end
end
