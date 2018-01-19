module SpoilerFreeSoccerPlayByPlayReports

    
    class Formatter


        ###################
        # CLASS CONSTANTS #
        ###################
        COLUMN_WIDTH = 50
        INDENT = "     "


        ########################
        # PUBLIC CLASS METHODS #
        ########################
        def self.columnize(string_array, column_width = COLUMN_WIDTH)
            odd_end = string_array.size.even? ? nil : string_array.pop

            columnized_string = ""
            for i in 0...half_way = string_array.size / 2
                columnized_string << row(column_width, strings[i], strings[i+half_way])
            end

            columnized_string << odd_end if odd_end
        end

        def self.indent(string)
            return if !string.is_a?(String)

            string.prepend(INDENT) # STUB, need to account for multi-line strings
        end


        #########################
        # PRIVATE CLASS METHODS #
        #########################
        def self.row(column_width, left_string, right_string)
            row = ""
            row << left_string
            row << (" " * (column_width - left_string.size))
            row << right_string
            row << "\n"
        end

        private_class_method :row
    end
end