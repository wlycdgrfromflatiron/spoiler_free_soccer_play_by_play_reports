class Printer
    INDENT = "     "

    def self.clear_screen
        system "clear" or system "cls"
    end

    def self.line_feed(number = 1)
        number.times do
            puts ""
        end
    end

    def self.print(string_or_string_array)
        if string_or_string_array.is_a?(String)
            print_string(string_or_string_array)
        
        elsif string_or_string_array.is_a?(Array)
            last_paragraph = string_or_string_array.pop
            string_or_string_array.each do |string|
                print_string(string)
                self.line_feed(2)
            end
            print_string(last_paragraph)
        end
    end
    
    # Private
    def self.print_string(string)
        puts string.prepend(INDENT)
    end

    private_class_method :print_string
end