class ResolverStacker
  attr_reader :r

  def initialize(&resolver)
    @r = resolver
  end

  def add(&resolver)
    old_resolver = @r
    @r = lambda do |obj, args, ctx|
      ctx[:stack] = old_resolver.call(obj, args, ctx)
      resolver.call(obj, args, ctx)
    end
    self
  end

  def paginate
    add do |obj, args, ctx|
      ctx[:stack] = ctx[:stack].limit([30, args[:limit]].min)
      if args[:offset]
        ctx[:stack] = ctx[:stack].offset(args[:offset])
      end
      ctx[:stack]
    end
  end
end