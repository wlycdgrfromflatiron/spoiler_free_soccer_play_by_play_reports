module SpoilerFreeSoccerPlayByPlayReports
    class CLI
        def self.start
            self.welcome
            self.controls
            self.prompt_loop
        end

        def self.welcome
            puts "" 
            puts "~ Welcome Spoiler Free Soccer Play by Play Reports ~"
            puts "(data provided by Sportsmole)"
            puts "" 
        end

        def self.controls
            puts ""
            puts "Controls:"
            puts "[club's name]: List avialable reports for that EPL club"
            puts "'all': List available reports for all EPL clubs"
            puts "[report list index]: View the corresponding report"
            puts "'controls', 'help': See these instructions"
            puts "'exit', 'quit': Quit the program"
            puts ""
        end

        def self.prompt_loop
            input = nil
            while ('exit' != input && 'quit' != input)
                puts 'Enter command: '
                
                input = gets.strip.downcase

                if input.to_i > 0
                    self.report(input.to_i)
                else
                    case input
                    when 'chelsea', 'arsenal', 'city', 'all'
                        self.report_list(input)
                    when 'controls', 'help'
                        self.controls
                    else 
                        self.invalid_input
                    end
                end
            end
        end

        def self.report(report_index)
            puts ""
            puts "CLI.report called with report_index: #{report_index}"
            puts ""
        end

        def self.report_list(team_name)
            puts ""
            puts "CLI.report_list called with team_name: #{team_name}"
            puts ""
        end

        def self.invalid_input
            puts ""
            puts "CLI.invalid_input called"
            puts ""
        end
    end
end
  