module Enumerable
  
  def average
    if empty?
      return 0
    end
    sum.to_f / size
  end
  
end