  class RMQ
    def root_element
      self.activity.root_element
    end

    def activity
      # TODO use the real one
      RMQApp.current_activity
    end
    alias :screen :activity

    def filter(opts = {}, &block)
      out = []
      limit = opts[:limit]

      selected.each do |view|
        results = yield(view)
        unless RMQ.is_blank?(results)
          out << results
          break if limit && (out.length >= limit)
        end
      end
      out.flatten!
      out = out.uniq if opts[:uniq]

      if opts[:return_array]
        out
      else
        RMQ.create_with_array_and_selectors(out, selectors, @originated_from, self)
      end
    end

    def all
      wrap(root_element).find
    end

    def children(*working_selectors)
      normalize_selectors(working_selectors)

      filter do |view|
        subviews = view.subviews

        if RMQ.is_blank?(working_selectors)
          subviews
        else
          subviews.inject([]) do |out, subview|
            out << subview if match(subview, working_selectors)
            out
          end
        end
      end
    end
    alias :subviews :children

    def find(*working_selectors)
      normalize_selectors(working_selectors)

      filter(uniq: true) do |view|
        subviews = all_subviews_for(view)

        if RMQ.is_blank?(working_selectors)
          subviews
        else
          subviews.inject([]) do |out, subview|
            out << subview if match(subview, working_selectors)
            out
          end
        end
      end # filter

    end
  end
