class EasyFormBuilder < ActionView::Helpers::FormBuilder
  include ActionView::Helpers::TagHelper
  class_eval do
    %w(text_field password_field text_area check_box select calendar_date_select).each do |name|
      define_method name do |args|
        attribute, options = args
        if options.is_a?(Hash)
          extra_stuff = options.delete :extra_stuff
        end
        content_tag(:div, label(attribute) + super + extra_stuff.to_s)
      end
    end
  end
end