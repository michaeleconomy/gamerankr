class Array
  def delete_unless
    delete_if do |i|
      !yield(i)
    end
  end
end