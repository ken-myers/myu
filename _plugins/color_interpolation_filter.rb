module Jekyll
    module ColorInterpolationFilter
      def interpolate_color(value, n, *args)
        value = value.to_f
        n = n.to_f
  
        # Validate input
        if args.length % 2 != 0
          raise ArgumentError, "Expected an even number of color and proportion arguments."
        end
  
        # Parse colors and proportions
        colors = []
        proportions = []
  
        args.each_slice(2) do |color_hex, proportion|
          colors << color_hex.strip
          proportions << proportion.to_f
        end
  
        # Normalize proportions if necessary
        total_proportion = proportions.inject(0, :+)
        if total_proportion != 1.0
          proportions.map! { |p| p / total_proportion }
        end
  
        # Calculate cumulative proportions
        cumulative_proportions = proportions.each_with_index.map do |p, i|
          proportions[0..i].inject(0, :+)
        end
  
        # Calculate the position in the gradient (from 0.0 to 1.0)
        position = value / n
        position = position.clamp(0.0, 1.0) # Ensure position is within 0.0 to 1.0
  
        # Find the two colors to interpolate between
        index = cumulative_proportions.find_index { |cp| cp >= position }
        if index.nil?
          index = colors.length - 1
        end
  
        if index == 0
          color_start = colors[0]
          color_end = colors[0]
          t = 0.0
        else
          color_start = colors[index - 1]
          color_end = colors[index]
          proportion_start = cumulative_proportions[index - 1]
          proportion_end = cumulative_proportions[index]
          # Normalize t between 0 and 1
          t = (position - proportion_start) / (proportion_end - proportion_start)
        end
  
        # Convert hex colors to RGB
        rgb_start = hex_to_rgb(color_start)
        rgb_end = hex_to_rgb(color_end)
  
        # Interpolate between the two colors
        interpolated_rgb = interpolate_rgb(rgb_start, rgb_end, t)
  
        # Convert RGB back to hex
        rgb_to_hex(interpolated_rgb)
      end
  
      private
  
      # Convert hex color to RGB array
      def hex_to_rgb(hex)
        hex = hex.delete('#')
        if hex.length == 3
          hex = hex.chars.map { |c| c * 2 }.join
        end
        hex.scan(/../).map { |component| component.to_i(16) }
      end
  
      # Convert RGB array to hex color
      def rgb_to_hex(rgb)
        '#' + rgb.map { |component|
          component.round.clamp(0, 255).to_s(16).rjust(2, '0')
        }.join
      end
  
      # Interpolate between two RGB colors
      def interpolate_rgb(rgb_start, rgb_end, t)
        rgb_start.zip(rgb_end).map { |start, finish|
          start + (finish - start) * t
        }
      end
    end
  end
  
  Liquid::Template.register_filter(Jekyll::ColorInterpolationFilter)