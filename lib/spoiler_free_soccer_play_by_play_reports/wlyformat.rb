module WlyCuteConsole
    module ClassMethods
        DEFAULT_PUTS_INDENT = 2

        @@puts_indent = nil

        def set_default_puts_indent(indent_value)
            @@puts_indent = indent_value if indent_value.to_i > 0
        end

        def puts_indented(string, indent = @@puts_indent || DEFAULT_PUTS_INDENT)
            puts string.prepend(" " * indent)
        end
    end
end