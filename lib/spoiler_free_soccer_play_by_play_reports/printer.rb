module SpoilerFreeSoccerPlayByPlayReports


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

        def self.print(string)
            print Formatter.indent(string)
        end

        def self.puts(string_or_strings)
            string_or_strings = [string_or_strings] if string_or_strings.is_a?(String)
            string_or_strings.each do |string|
                puts Formatter.indent(string)
                puts ""
            end 
        end
    end
end