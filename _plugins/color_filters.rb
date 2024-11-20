# _plugins/color_filters.rb

module Jekyll
    module ColorFilters
      def darken(hex_color, factor)
        # Validate the inputs
        unless hex_color.match?(/^#(?:[0-9a-fA-F]{3}|[0-9a-fA-F]{6})$/)
          raise ArgumentError, "Invalid hex color format: #{hex_color}"
        end
  
        factor = factor.to_f
        if factor < 0.0 || factor > 1.0
          raise ArgumentError, "Darken factor must be between 0.0 and 1.0"
        end
  
        # Convert hex to RGB
        rgb = hex_to_rgb(hex_color)
  
        # Darken each channel
        darkened_rgb = rgb.map { |channel| (channel * (1.0 - factor)).round }
  
        # Convert back to hex
        rgb_to_hex(darkened_rgb)
      end
  
      private
  
      # Convert hex color to RGB array
      def hex_to_rgb(hex)
        hex = hex.delete('#')
        hex = hex.chars.map { |c| c * 2 }.join if hex.length == 3 # Expand shorthand hex
        hex.scan(/../).map { |component| component.to_i(16) }
      end
  
      # Convert RGB array to hex color
      def rgb_to_hex(rgb)
        '#' + rgb.map { |component| component.clamp(0, 255).to_s(16).rjust(2, '0') }.join
      end
    end
  end
  
  Liquid::Template.register_filter(Jekyll::ColorFilters)
  