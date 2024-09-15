module RpgAi
  module Templates
    def self.get(name)
      template_file = filename(name)
      
      if File.exist?(template_file)
        if Rails.env.production?
          @templates ||= {}
          @templates[method] ||= load_template(template_file)
        else
          load_template(template_file)
        end
      else
        nil
      end
    end

    def self.load_template(file)
      ERB.new(File.read(file), trim_mode: '-')
    end

    def self.filename(method)
      File.join(__dir__, 'templates', "#{method}.erb")
    end
  end
end