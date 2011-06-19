module TagHelper
  
  %w(div a span).each do |tag|
    class_eval "
      def #{tag}_tag(contents, options = {})
        content_tag(:#{tag}, contents, options)
      end"
  end
end