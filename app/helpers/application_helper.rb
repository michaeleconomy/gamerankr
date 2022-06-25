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


  def platform_image(platform, size, options = {})
    image_url = platform.giant_bomb_platform && platform.giant_bomb_platform.resized_image_url(size)
    if options[:class]
      options[:class] << " #{size.downcase}"
    else
      options[:class] = size.downcase
    end
    if image_url
      options.merge! :alt => platform.name, :title => platform.name
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
   class_name = 
      if size
        "#{size}UserPhoto"
      else
        "userPhoto"
      end
    image_tag(user.photo_url(size), class: class_name)
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
    options[:remote] = true
    link_to(copy, options) + h("<div class='loading hidden'></div>")
  end
  
  def link_to_fb_connect
    link_to image_tag("fb-login-button.png", :alt => 'login with facebook'),
      "/auth/facebook",
      :id => "fb_auth_button",
      :method => :post,
      :rel => "nofollow"
  end

  def link_to_fb_request_permissions
    link_to "Grant Additional Permissions on Facebook",
      "/auth/facebook?auth_type=rerequest",
      :method => :post,
      class: "button"
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

  def platform_list(game, first = nil)
    ports = game.ports.to_a
    if first
      ports.delete(first)
      ports.unshift(first)
    end
    output = "<span class=\"platforms\">("
    links = ports[0,3].collect do |p|
      link_to(p.platform.to_display_name, p, itemprop: "gamePlatform")
    end
    if ports[3]
      links << "&hellip;"
    end

    output << links.join(", ")

    output << ")</span>"

    output.html_safe
  end

  FEATURED_PLATFORMS = ["PlayStation 4", "Xbox One", "Nintendo Switch", "PC", "Mac", "iPhone", "Android"]
  
  def featured_platforms
    platforms_raw = Platform.where(name: FEATURED_PLATFORMS).all.index_by(&:name)
    @platforms = FEATURED_PLATFORMS.collect{|p| platforms_raw[p]}
    if @platforms.size != FEATURED_PLATFORMS.size
      logger.warn "not all FEATURED_PLATFORMS were found!"
    end
    @platforms
  end
end
