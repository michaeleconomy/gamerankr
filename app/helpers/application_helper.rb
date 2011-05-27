module ApplicationHelper
  
  def date(d)
    r = d.strftime("%B")
    r << " " + d.mday.ordinalize
    r << ", #{d.year}" if d.year != Date.today.year
    
    r
  end
  
  def amazon_image(port, size, options = {})
    image_url = port.resized_amazon_image_url(size)
    if image_url
      options.merge! :alt => port.title, :title => port.title
      image_tag(image_url, options)
    else
      size_px = size[/(\d+)/].to_i
      style = "width:#{size_px}px"
      if size_px < 100
        #TODO
      end
      options.merge! :style => style
      content_tag('span', 'image unavailable', options)
    end
  end
    
  def h1_title(t)
    content_tag("h1", @title = t)
  end
  
  def text_field_tag(name, value = nil, options = {})
    if default_text = options.delete(:default_text)
      options[:id] ||= rand(100000000)
      return super(name, value, options) +
        javascript_tag("default_text_area('#{options[:id]}', '#{escape_javascript default_text}')", {})
    end
    super(name, value, options)
  end
  
  
  def link_to_ar(ar, options = {})
    link_to ar.to_display_name, ar, options
  end
  
  def link_to_remote_loading(copy, options)
    options[:html] ||= {}
    options[:html][:id] ||= rand(100000000)
    loading_id = "#{options[:html][:id]}_loading"
    (options[:loading] ||= "") << ";$('#{loading_id}').show();$('#{options[:html][:id]}').hide();"
    (options[:complete] ||= "") << ";$('#{loading_id}').hide();$('#{options[:html][:id]}').show();"
    (options[:failure] ||= "") << ";alert('ajax request failed');"
    link_to_remote(copy, options) + loading(:id => loading_id, :style => 'display:none')
  end
  
  def link_to_fb_connect
    link_to image_tag("fb-login-button.png", :alt => 'login with facebook'), "/auth/facebook"
  end
  
  def loading(options = {})
    content_tag(:div, nil, options.merge(:class => 'loading'))
  end
  
  def render_ar(ar, options = {})
    if ar.is_a?(Array)
      options[:collection] = ar
      klass = ar.first.class
    elsif ar.is_a?(ActiveRecord::Base)
      options[:object] = ar
      klass = ar.class
    else
      return
    end
    klass_name = klass.to_s.underscore
    options[:partial] = "#{klass_name.pluralize}/#{klass_name}"
    render options 
  end
  
  
  def comments_for(resource)
    @comment = Comment.new :resource => resource
    @comments = resource.comments.paginate :page => @page
    render :partial => 'comments/comments_for', :locals => {:resource => resource}
  end
  
  def current_shelves
    @current_shelves ||= signed_in? ? current_user.shelves.limit(10) : Shelf::DEFAULTS
  end
  
  def format_price(amount)
    "$#{("%.2f" % (amount.to_f / 100))}"
  end
end
