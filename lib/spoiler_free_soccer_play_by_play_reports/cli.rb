module SpoilerFreeSoccerPlayByPlayReports
    class CLI
        def self.start
            self.welcome
            self.controls
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
    end
end
  