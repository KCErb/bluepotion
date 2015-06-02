# http://hipbyte.myjetbrains.com/youtrack/issue/RM-773 - can't put this in a module yet :(
# module ProMotion
  module PMScreenModule
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      attr_reader :xml_resource, :show_action_bar, :bars_title

      @show_action_bar = true

      def stylesheet(style_sheet_class)
        @rmq_style_sheet_class = style_sheet_class
      end

      def rmq_style_sheet_class
        @rmq_style_sheet_class
      end

      def layout(xml_resource=nil)
        @xml_resource = xml_resource ||= deduce_resource_id
      end
      alias_method :uses_xml, :layout

      def action_bar(show_action_bar)
        @show_action_bar = show_action_bar
      end
      alias_method :nav_bar, :action_bar
      alias_method :uses_action_bar, :action_bar

      def title(new_title)
        @bars_title = new_title
        #self.activity.title = new_title
        #getActivity().getActionBar().setTitle("abc")
      end

      private

      def deduce_resource_id
        resource = self.name.split(".").last
        resource.underscore.to_sym
      end
    end

    def rmq_data
      @_rmq_data ||= RMQScreenData.new
    end

    def stylesheet
      self.rmq.stylesheet
    end

    def stylesheet=(value)
      self.rmq.stylesheet = value
    end

    def rmq(*working_selectors)
      crmq = (rmq_data.cached_rmq ||= RMQ.create_with_selectors([], self))

      if working_selectors.length == 0
        crmq
      else
        RMQ.create_with_selectors(working_selectors, self, crmq)
      end
    end

    def root_view
      self.getView
    end

    def on_load
      # abstract
    end

    def color(*params)
      RMQ.color(*params)
    end

    def font
      rmq.font
    end

    def image
      rmq.image
    end

    def append(view_or_class, style=nil, opts={}, dummy=nil)
      self.rmq.append(view_or_class, style, opts)
    end

    def append!(view_or_class, style=nil, opts={})
      self.rmq.append(view_or_class, style, opts).get
    end

    # TODO add create and build


    # temporary stand-in for Java's R class
    def r(resource_type, resource_name)
      resources.getIdentifier(resource_name.to_s, resource_type.to_s,
                              activity.getApplicationInfo.packageName)
    end

    def show_toast(message)
      Android::Widget::Toast.makeText(activity, message, Android::Widget::Toast::LENGTH_SHORT).show
    end

    def open(screen_class, options={})
      mp "ScreenModule open", debugging_only: true
      activity_class = options[:activity] || PMSingleFragmentActivity

      # TODO: replace the fragment in the activity when possible
      # replace the fragment if we can; otherwise launch a new activity
      # we're taking a conservative approach for now - eventually we'll want to allow
      # replacing fragments for any kind of activity, but I'm not sure of the best way
      # to implement that yet
      intent = Android::Content::Intent.new(self.activity, activity_class)
      intent.putExtra PMSingleFragmentActivity::EXTRA_FRAGMENT_CLASS, screen_class.to_s

      ## TODO: limited support for extras for now - should reimplement with fragment arguments
      if options[:extras]
        options[:extras].keys.each do |key|
          intent.putExtra key.to_s, options[:extras][key].toString
        end
      end

      self.activity.startActivity intent
    end

    def close(options={})
      self.activity.finish
    end

    def start_activity(activity_class)
      intent = Android::Content::Intent.new(self.activity, activity_class)
      #intent.putExtra("key", value); # Optional parameters
      self.activity.startActivity(intent)
    end

    def soft_input_mode(mode)
      mode_const =
        case mode
        when :adjust_resize
          Android::View::WindowManager::LayoutParams::SOFT_INPUT_ADJUST_RESIZE
        end
      activity.getWindow().setSoftInputMode(mode_const)
    end

    def hide_keyboard
      input_manager = activity.getSystemService(Android::Content::Context::INPUT_METHOD_SERVICE)
      input_manager.hideSoftInputFromWindow(view.getWindowToken(), 0);
    end


    def activity
      getActivity()
    end

    def action_bar
      activity.getActionBar()
    end

    def menu
      activity.menu
    end

    # Example: set_action_bar_button :right, { title: "My text", show: :if_room }
    def set_action_bar_button(side, options={})
      unless menu
        mp "#{self.inspect}#set_action_bar_button: No menu set up yet."
        return
      end

      option[:show] ||= :always

      # Should be something like Android::MenuItem::SHOW_AS_ACTION_IF_ROOM
      show_as_action = 0 if options[:show] == :never
      show_as_action = 1 if options[:show] == :if_room
      show_as_action = 2 if options[:show] == :always
      show_as_action = 4 if options[:show] == :with_text
      show_as_action = 8 if options[:show] == :collapse

      if side == :left
        mp "#{self.inspect}#set_action_bar_button: Left bar buttons not implemented yet."
      elsif side == :right
        btn = self.activity.menu.add(options.fetch(:group, 0), options.fetch(:item_id, 0), options.fetch(:order, 0), options.fetch(:title, "Untitled"))
        btn.setShowAsAction(show_as_action) if show_as_action
        btn.setIcon(options[:icon]) if options[:icon]
      end
      btn
    end
    alias_method :set_nav_bar_button, :set_action_bar_button


  end
#end
