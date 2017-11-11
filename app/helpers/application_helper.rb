module ApplicationHelper
  
  def date(d)
    r = d.strftime("%B")
    r << " " + d.mday.ordinalize
    r << ", #{d.year}" if d.year != Date.today.year
    r
  end
  
  def port_image(port, size, options = {})
    image_url = port.resized_image_url(size)
    if options[:class]
      options[:class] << " #{size.downcase}"
    else
      options[:class] = size.downcase
    end
    if image_url
      options.merge! :alt => port.title, :title => port.title
      image_tag(image_url, options)
    else
      content_tag('span', 'image unavailable', options)
    end
  end
    
  def h1_title(t)
    content_tag("h1", @title = t)
  end
  
  def user_photo(user, size = nil)
    return "no photo" unless user
    return "fb not connected" unless user.facebook_user
    image_tag(user_photo_url(user, size))
  end
  
  
  def user_photo_url(user, size = nil)
    facebook_photo_url(user.facebook_user.uid, size)
  end
  
  # valid sizes are:  square, small, normal, and large
  def facebook_photo_url(facebook_uid, size = nil)
    url = 'http://graph.facebook.com/' + facebook_uid + '/picture'
    if size
      url += "?type=#{size}"
    end
    # TODO, support the width and height parameters also!
    url
  end
  
  def link_to_ar(ar, options = {})
    return unless ar
    link_to ar.to_display_name, ar, options
  end
  
  def link_to_remote_loading(copy, options)
    options[:html] ||= {}
    options[:html][:id] ||= rand(100000000)
    loading_id = "#{options[:html][:id]}_loading"
    (options[:loading] ||= "") << ";$('##{loading_id}').show();$('##{options[:html][:id]}').hide();"
    (options[:complete] ||= "") << ";$('##{loading_id}').hide();$('##{options[:html][:id]}').show();"
    (options[:failure] ||= "") << ";alert('ajax request failed');"
    link_to_remote(copy, options) + "<div class='loading hidden'></div>"
  end
  
  def link_to_fb_connect
    link_to image_tag("fb-login-button.png", :alt => 'login with facebook'), "/auth/facebook", :rel => "nofollow"
  end
  
  def render_ar(ar, options = {})
    if ar.is_a?(ActiveRecord::Relation)
      ar = ar.all
    end
    
    if ar.is_a?(Array) || ar.is_a?(ActiveRecord::AssociationRelation)
      if ar.empty?
        return "no items in set"
      end
      options[:collection] = ar
      klass = ar.first.class
    elsif ar.is_a?(ActiveRecord::Base)
      options[:object] = ar
      klass = ar.class
    else
      raise "don't know how to render type: #{ar.class}"
    end
    klass_name = klass.to_s.underscore
    options[:partial] = "#{klass_name.pluralize}/#{klass_name}"
    logger.info "#{options}"
    render options 
  end
  
  def current_shelves
    @current_shelves ||= signed_in? ? current_user.shelves.limit(10) : Shelf::DEFAULTS
  end
  
  def format_price(amount)
    "$#{("%.2f" % (amount.to_f / 100))}"
  end
  
  
  def format_decimal(decimal)
    "%.2f" % decimal
  end
end
