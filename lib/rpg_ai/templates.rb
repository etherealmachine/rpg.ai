module RpgAi
  module Templates
    def self.method_missing(method, *args, &block)
      template_file = filename(method)
      
      if File.exist?(template_file)
        if Rails.env.production?
          @templates ||= {}
          @templates[method] ||= load_template(template_file)
        else
          load_template(template_file)
        end
      else
        super
      end
    end

    def self.respond_to_missing?(method, include_private = false)
      File.exist?(filename) || super
    end

    def self.load_template(file)
      ERB.new(File.read(file), trim_mode: '-')
    end

    def self.filename(method)
      File.join(__dir__, 'templates', "#{method}.erb")
    end
  end
end