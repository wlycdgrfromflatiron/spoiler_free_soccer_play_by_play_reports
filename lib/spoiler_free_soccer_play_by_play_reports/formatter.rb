module SpoilerFreeSoccerPlayByPlayReports
    class Formatter
        COLUMN_WIDTH = 50
        INDENT = "     "
        MINIMUM_COLUMNN_GAP = 2

        # PUBLIC CLASS METHODS 
        def self.columnize(string_array, column_width = COLUMN_WIDTH)
            column_width = validate_column_width(string_array, column_width)

            odd_end = string_array.size.even? ? nil : string_array.pop

            columnized_string = ""
            for i in 0...half_way = string_array.size / 2
                columnized_string << row(column_width, strings[i], strings[i+half_way])
            end

            columnized_string << odd_end if odd_end
        end

        def self.indent(string)
            return if !string.is_a?(String)

            indented_string = INDENT + string
            indented_string.gsub(/(\n)/, "\\1#{INDENT}")
        end

    
        # PRIVATE CLASS METHODS
        def self.row(column_width, left_string, right_string)
            row = ""
            row << left_string
            row << (" " * (column_width - left_string.size))
            row << right_string
            row << "\n"
        end

        def self.validate_column_width(string_array, column_width)
            half_way = string_array.size.even ? string_array.size / 2 : (string_array.size + 1) / 2

            for i in 0...half_way
                min_required_width = string_array[i].length + MINIMUM_COLUMN_GAP
                column_width = min_required_width if min_required_width > column_width
            end

            column_width
        end

        private_class_method :row, :validate_column_width
    end # class Formatter
end # module SpoilerFreeSoccerPlayByPlayReports