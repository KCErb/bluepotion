class RMQ
  # Do not use
  def selectors=(value)
    @selected_dirty = true
    normalize_selectors(value)
    @_selectors = value
  end

  def selectors
    @_selectors
  end

  def match(view, new_selectors)
    new_selectors.each do |selector|
      if selector == :tagged
        return true unless view.rmq_data.has_tag?
      elsif selector.is_a?(Hash)
        return true if match_hash(view, selector)
      elsif selector.is_a?(Symbol)
        return true if (view.rmq_data.has_style?(selector)) || view.rmq_data.has_tag?(selector)
      elsif selector.is_a?(Java::Lang::Integer)
        return true if view.getId == selector
      elsif RMQ.is_class?(selector)
        return true if view.is_a?(selector)
      else
        return true if view == selector
      end
    end

    false
  end

  private

  def match_hash(view, hash)
    # TODO, check speed, and do sub hashes for stuff like origin
    # it's probably pretty slow
    hash.each do |k,v|
      return true if view.respond_to?(k) && (view.send(k) == v)
    end
    false
  end

  def normalize_selectors(a = self.selectors)
    a.flatten! if a
    a
  end
end
