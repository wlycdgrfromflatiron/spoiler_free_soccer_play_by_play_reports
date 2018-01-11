module SpoilerFreeSoccerPlayByPlayReports
    class CLI
        def self.start
            self.welcome
            self.controls
            self.prompt_loop
            self.goodbye
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
            puts "List [All | [team name]]: list the available reports for all teams or a specific team. Defaults to all."
            puts "[report #]: View the corresponding report"
            puts "'Help': See these instructions"
            puts "'Exit', 'Quit': Quit the program"
            puts ""
        end

        def self.prompt_loop
            input = nil
            while ('exit' != input && 'quit' != input && 'e' != input && 'q' != input)
                print "List [All | [team name]]  ||  [report #]  ||  Help  ||  Exit: "
                
                input = gets.strip.downcase

                if input.to_i > 0
                    self.report(input.to_i)
                else
                    case input
                    when 'l', 'l a', 'l all', 'list', 'list a', 'list all'
                        self.report_list('all')
                    when 'l arsenal', 'l chelsea'
                        self.report_list(input.gsub(/^\S+\s/, ""))
                    when 'h', 'help'
                        self.controls
                    when 'e', 'exit'
                        # do nothing
                    else 
                        self.controls
                    end
                end
            end
        end

        def self.report(report_index)
            puts ""
            puts "CLI.report called with report_index: #{report_index}"
            puts ""

            puts "Match Report Preamble for #{report_index}"
            puts Report.preamble(report_index)

            puts ""
            puts "Spacebar: view next blurb"
            puts "q: quit"
            puts ""

            input = nil
            while ('q' != input && !Report.done)
                input = STDIN.getch

                if ' ' == input
                    blurb = Report.next_blurb
                    puts ""
                    puts "#{blurb.label}"
                    puts "#{blurb.text}"
                    puts ""
                end
            end
=begin
            while ('done' != input && !Report.done)
                print "Type 'n' to continue, 'done' to return: "

                input = gets.strip.downcase

                if 'n' == input
                    blurb = Report.next_blurb
                    puts ""
                    puts "#{blurb.label}"
                    puts "#{blurb.text}"
                    puts ""
                end
            end
=end
            if 'done' == input
                puts ""
                puts "Returning to main menu early!"
                puts ""
            elsif Report.done
                puts Report.conclusion
            end
        end

        def self.report_list(team_name)
            puts ""
            puts "CLI.report_list called with team_name: #{team_name}"
            puts ""
            
            Report.list(team_name).each.with_index(1) do |report, index|
                puts "#{index}. #{report.team1} vs. #{report.team2}"
            end
        end

        def self.invalid_input
            puts ""
            puts "CLI.invalid_input called"
            puts ""
        end

        def self.goodbye
            puts ""
            puts "Thanks for using this app. Goodbye!"
            puts ""
        end
    end
end
  