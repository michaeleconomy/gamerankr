class String
  def pluralize_optionally(number)
    number == 1 ? self : pluralize
  end
end