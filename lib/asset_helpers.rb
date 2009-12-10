module Sinatra
  module StaticAssets
    module Helpers

      def js_include_tag(path)
        if production?
          timestamp = get_timestamp("#{path}.js")
          path = "#{path}.min.js?#{timestamp}"
        else
          path = "#{path}.js"
        end

        %Q{<script type="text/javascript" src="#{path}"></script>}
      end

      def css_include_tag(path)
        if production?
          timestamp = get_timestamp("#{path}.css")
          path = "#{path}.min.css?#{timestamp}"
        else
          path = "#{path}.css"
        end

        %Q{<link type="text/css" rel="stylesheet" media="screen" href="#{path}" />}
      end

      private
      def get_timestamp(path)
        File.mtime(File.join(options.public, path)).to_i.to_s
      end
    end
  end

  helpers StaticAssets::Helpers
end