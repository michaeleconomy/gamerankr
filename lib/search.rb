
class Hpricot::Elements
  def inner_html_at(str)
    node = at(str)
    node ? node.inner_html : nil
  end
end

class Search
end