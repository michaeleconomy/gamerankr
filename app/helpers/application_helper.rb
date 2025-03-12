module ApplicationHelper
  
  def date(d)
    r = d.strftime("%B")
    r += " " + d.mday.ordinalize
    r += ", #{d.year}" if d.year != Date.today.year
    r
  end
  
  def port_image(port, size, options = {})
    image_url = nil
    if port
      image_url = port.resized_image_url(size)
    end
    if !image_url
      image_url = unavailable_resized_image_url(size)
    end
    if options[:class]
      options[:class] += " #{size.downcase}"
    else
      options[:class] = size.downcase
    end
    
    options.merge! alt: port && port.title, title: port && port.title
    image_tag(image_url, options)
  end


  def unavailable_resized_image_url(size)
    size_px = size.gsub(/[^\d]/, "").to_i
    if size_px <= 100
      image_url("thumb.png")
    else
      image_url("cover.png")
    end
  end

  def sort_dropdown
    render partial: "shared/sort_dropdown"
  end

  def errors_for(o)
    if !o
      return ""
    end
    if !o.errors.any?
      return ""
    end
    render partial: 'shared/errors_for', locals: {o: o}
  end


  def platform_image(platform, size, options = {})
    image_url = platform.giant_bomb_platform && platform.giant_bomb_platform.resized_image_url(size)
    if options[:class]
      options[:class] += " #{size.downcase}"
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
  
  def user_photo(user, size = nil, options = {})
    class_name = 
      if size
        "#{size}UserPhoto"
      else
        "userPhoto"
      end
    if options[:additionalClass]
      class_name += " " + options[:additionalClass]
    end
    return image_tag("default_profile.jpg", class: class_name)
  end
  
  def link_to_ar(ar, options = {})
    return unless ar
    url = ar
    if ar.is_a?(Port)
      url = game_path(ar.game, port_id: ar.id)
    end
    link_to ar.to_display_name, url, options
  end
  
  def link_to_remote_loading(copy, options)
    options[:html] ||= {}
    options[:html][:id] ||= rand(100000000)
    loading_id = "#{options[:html][:id]}_loading"
    if !options[:loading]
      options[:loading] = ""
    end
    options[:loading] += ";$('##{loading_id}').show();$('##{options[:html][:id]}').hide();"

    if !options[:complete]
      options[:complete] = ""
    end
    options[:complete] += ";$('##{loading_id}').hide();$('##{options[:html][:id]}').show();"

    if !options[:failure]
      options[:failure] = ""
    end
    options[:failure] += ";alert('ajax request failed');"
    options[:remote] = true
    link_to(copy, options) + h("<div class='loading hidden'></div>")
  end
  
  def render_ar(ar, options = {})
    if ar.is_a?(Array) || ar.is_a?(ActiveRecord::AssociationRelation) || ar.is_a?(ActiveRecord::Relation)
      if ar.empty?
        return "no items in set"
      end
      options[:collection] = ar
      klass = ar.first.class
    elsif ar.is_a?(ActiveRecord::Base)
      options[:object] = ar
      klass = ar.class
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
    output = "<span class=\"platforms\">"
    links = ports[0,3].collect do |p|
      link_to(p.platform.short, game_path(game, port_id: p.id), itemprop: "gamePlatform")
    end
    if ports[3]
      links << "&hellip;"
    end

    output += links.join(", ")

    output += "</span>"

    output.html_safe
  end

  def featured_platforms
    @platforms = Platform.featured
  end

  def release_date(date, accuracy)
    date = date.to_date
    if accuracy == "year"
      return date.year
    end
    if accuracy == "day"
      return "#{Date::MONTHNAMES[date.month]} #{date.day.ordinalize} #{date.year}"
    end
    "#{Date::MONTHNAMES[date.month]} #{date.year}"
  end
end
