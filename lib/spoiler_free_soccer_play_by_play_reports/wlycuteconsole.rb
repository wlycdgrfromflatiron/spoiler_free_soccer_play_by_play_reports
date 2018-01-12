module WlyCuteConsole
    module ClassMethods
        DEFAULT_PUTS_INDENT = 2
        DEFAULT_PRINT_INDENT = 2
        DEFAULT_COLUMN_PRINT_SETTINGS = {
            # :column_count => 2, - for ifwhen a more generic version of column_print becomes useful
            :column_width => 50
        }

        @@puts_indent = DEFAULT_PUTS_INDENT
        @@print_indent = DEFAULT_PRINT_INDENT

        def set_default_puts_indent(indent_value)
            @@puts_indent = indent_value if indent_value.to_i > 0
        end

        def set_default_print_indent(indent_value)
            @@print_indent = indent_value if indent_value.to_i > 0
        end

        def puts_indented(string, indent = @@puts_indent || DEFAULT_PUTS_INDENT)
            puts string.prepend(" " * indent)
        end

        def print_indented(string, indent = @@print_indent || DEFAULT_PRINT_INDENT)
            print string.prepend(" " * indent)
        end

        def column_print(strings, settings=DEFAULT_COLUMN_PRINT_SETTINGS)
            columnized_string = ""

            column_width = settings[:column_width] || DEFAULT_COLUMN_PRINT_SETTINGS[:column_width]
            indent_string = " " * (settings[:indent] || @@print_indent)

            string_count = strings.size
            half_way = string_count.even? ? string_count / 2 : (string_count+1) / 2

            left_string = "", right_string = ""
            for i in 0...half_way
                left_string = strings[i]
                columnized_string << indent_string << left_string
                if right_string = strings[i+half_way]
                    columnized_string << (" " * (column_width - left_string.size))
                    columnized_string << right_string
                end
                columnized_string << "\n"
            end

            columnized_string
        end
    end
end