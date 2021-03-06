module Wheaties
  module Concerns
    module Formatting
      PLAIN = 15.chr
      BOLD = 2.chr
      ITALIC = 22.chr
      UNDERLINE = 31.chr
      
      COLOR = UNCOLOR = 3.chr
      COLORS = {
        :white => "00",
        :black => "01",
        :dark_blue => "02",
        :navy_blue => "02",
        :dark_green => "03",
        :red => "04",
        :brown => "05",
        :dark_red => "05",
        :purple => "06",
        :dark_yellow => "07",
        :olive => "07",
        :orange => "07",
        :yellow => "08",
        :green => "09",
        :lime => "09",
        :dark_cyan => "10",
        :teal => "10",
        :cyan => "11",
        :blue => "12",
        :royal_blue => "12",
        :magenta => "13",
        :pink => "13",
        :fuchsia => "13",
        :grey => "14",
        :gray => "14",
        :light_grey => "15",
        :light_gray => "15",
        :silver => "15"
      }
      
      ANY_FORMATTING = /(?:[#{PLAIN}#{BOLD}#{ITALIC}#{UNDERLINE}]+|#{COLOR}\d{1,2})+/
      
      def color(fore, back = nil, text = nil)
        return unless [Symbol, String].include?(fore.class)
        fore = fore.to_sym
        fore = :black unless COLORS.include?(fore)
        
        colored = "#{COLOR}#{COLORS[fore]}"
        
        if back && [Symbol, String].include?(back.class)
          return if back.is_a?(String) && back.empty?
          back = back.to_sym
          colored << ",#{COLORS[back]}" if COLORS.include?(back)
        end
        
        colored << "#{text}#{uncolor}" if text.is_a?(String) && !text.empty?
        colored
      end
      alias_method :c, :color
      alias_method :co, :color
      
      def uncolor(text = nil)
        if text.nil? || text.empty?
          UNCOLOR
        else
          text.gsub(/#{COLOR}\d{0,2},?\d{0,2}/, "")
        end
      end
      alias_method :uc, :uncolor
      
      COLORS.each do |name, code|
        define_method(name) do |*args|
          text, = *args
          color(name, nil, text)
        end
      end
      
      def colors; COLORS.keys; end
      
      def plain(text = nil)
        if text.nil? || text.empty?
          PLAIN
        else
          text.gsub(/[#{BOLD + ITALIC + UNDERLINE}]/, "")
        end
      end
      alias_method :pl, :plain
      
      def bold(text = nil)
        "#{BOLD}#{text.nil? || text.empty? ? "" : text + plain}"
      end
      alias_method :b, :bold
      
      def italic(text = nil)
        "#{ITALIC}#{text.nil? || text.empty? ? "" : text + plain}"
      end
      alias_method :i, :italic
      alias_method :reverse, :italic
      
      def underline(text = nil)
        "#{UNDERLINE}#{text.nil? || text.empty? ? "" : text + plain}"
      end
      alias_method :u, :underline
    end
  end
end

class String
  def unformat
    gsub Wheaties::Concerns::Formatting::ANY_FORMATTING, ""
  end
  
  def unformat!
    replace unformat
  end
end
