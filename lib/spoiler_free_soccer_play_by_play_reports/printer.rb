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

        def self.puts(strings)
            strings.each do |string|
                puts Formatter.indent(string)
                puts ""
            end 
        end
    end
end