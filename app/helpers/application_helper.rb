module ApplicationHelper
  def format_nil(value)
    if value.nil?
      "-"
    else
      value
    end
  end
end
