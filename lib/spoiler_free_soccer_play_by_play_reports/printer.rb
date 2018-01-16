class Printer
    ###################
    # CLASS CONSTANTS #
    ###################
    INDENT = "     "


    ########################
    # PUBLIC CLASS METHODS #
    ########################
    def self.clear_screen
        system "clear" or system "cls"
    end

    def self.line_feed(number = 1)
        number.times do
            puts ""
        end
    end

    def self.indented_print(string)
        print string.prepend(INDENT)
    end

    def self.padded_puts(string_or_string_array, top_padding = true, bottom_padding = false)
        if top_padding 
            puts ""
        end

        if string_or_string_array.is_a?(String)
            puts_string(string_or_string_array)
        
        elsif string_or_string_array.is_a?(Array)
            last_paragraph = string_or_string_array.pop
            string_or_string_array.each do |string|
                puts_string(string)
                self.line_feed(2)
            end
            puts_string(last_paragraph)
        end

        if bottom_padding
            puts ""
        end
    end
    

    #########################
    # PRIVATE CLASS METHODS #
    #########################
    def self.puts_string(string)
        string.gsub!(/\n/, "\n#{INDENT}");

        puts string.prepend(INDENT)
    end

    private_class_method :puts_string
end