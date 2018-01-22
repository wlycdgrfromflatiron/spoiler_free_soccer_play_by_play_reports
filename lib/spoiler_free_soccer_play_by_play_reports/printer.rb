module SpoilerFreeSoccerPlayByPlayReports


    class Printer


        ########################
        # PUBLIC CLASS METHODS #
        ########################
        def self.clear_screen
            system "clear" or system "cls"
            STDOUT.puts ""
        end

        def self.print(string)
            STDOUT.print Formatter.indent(string)
        end

        def self.puts(string_or_strings)
            string_or_strings = [string_or_strings] if string_or_strings.is_a?(String)
            string_or_strings.each do |string|
                STDOUT.puts Formatter.indent(string)
                STDOUT.puts ""
            end 
        end
    end
end