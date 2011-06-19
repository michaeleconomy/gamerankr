module TextHelper
  def truncate_with_link(text, size = 240)
    truncated_text = truncate(text, :length => size)
    if truncated_text != text
      span_tag(truncated_text) +
        a_tag("More", :class => "truncatedMoreLink") +
        span_tag(text, :class => "hidden")
    else
      text
    end
  end
end