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
        end

        def self.controls
            puts "Controls:"
            puts "[club's name]: See reports for that EPL club"
            puts "'all': See reports for all EPL clubs"
            puts "'controls', 'help': See these instructions"
            puts "'exit', 'quit': Quit the program"
        end
    end
end
  