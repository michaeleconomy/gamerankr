class ActiveRecord::Base
  def to_display_name
    "#{self.class}#{id}"
  end
end