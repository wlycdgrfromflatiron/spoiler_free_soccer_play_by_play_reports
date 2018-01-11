module WlyCuteConsole
    module ClassMethods
        DEFAULT_PUTS_INDENT = 2
        DEFAULT_PRINT_INDENT = 2

        @@puts_indent = nil
        @@print_indent = nil

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
    end
end