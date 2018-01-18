class Printer
    ###################
    # CLASS CONSTANTS #
    ###################
    COLUMN_WIDTH = 50
    INDENT = "     "


    ########################
    # PUBLIC CLASS METHODS #
    ########################
    def self.clear_screen
        system "clear" or system "cls"
    end

    def self.columnize(strings, column_width = COLUMN_WIDTH)
        string_count = strings.size
        half_way = string_count.even? ? string_count / 2 : (string_count+1) / 2

        columnized_string = ""
        for i in 0...half_way
            columnized_string << print_row(column_width, strings[i], strings[i+half_way])
        end

        columnized_string
    end

    def self.line_feed(number = 1)
        number.times do
            puts ""
        end
    end

    def self.indented_print(string)
        print string.prepend(INDENT)
    end

    def self.indented_puts(string_or_string_array)
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
    end
    

    #########################
    # PRIVATE CLASS METHODS #
    #########################
    def self.print_row(column_width, left_string, right_string)
        row_string = ""
        row_string << left_string
        if right_string
            row_string << (" " * (column_width - left_string.size))
            row_string << right_string
        end
        row_string << "\n"
    end

    def self.puts_string(string)
        string.gsub!(/\n/, "\n#{INDENT}");

        puts string.prepend(INDENT)
    end

    private_class_method :puts_string
end