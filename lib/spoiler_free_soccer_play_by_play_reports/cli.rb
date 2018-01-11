module SpoilerFreeSoccerPlayByPlayReports
    class CLI
        @@just_printed_report_list = false
        @@report_list_size = -1
        @@report_list_filter = "all"

        def self.start
            self.welcome
            self.controls
            self.main_loop
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
            puts "All:          List all available reports."
            puts "[team name]:  List all available reports involving [team name]."
            puts "[report #]:   View the corresponding report (available after printing a report list)."
            puts "[Spacebar]:   Show next report item (available on report detail screen)."
            puts "Help:         See these instructions."
            puts "Exit, 'Quit': Quit back to previous menu. If in main menu, quit."
            puts ""
        end

        def self.main_loop
            input = ""
            while (!input.match(/^e(xit)?\s*$/))
                @@just_printed_report_list = false

                print "MAIN MENU: All | [team name] |  Help  |  Exit: "
                
                input = gets.strip.downcase

                case input
                when /^a(ll)?\s*$/
                    self.report_list('all')
                when /^h(elp)?\s*$/
                    self.controls
                when /^e(xit)?\s*$/, "", /^\s*$/
                    # do nothing
                else
                    self.report_list(input)
                end

                if @@just_printed_report_list && @@report_list_size > 0
                    self.report_list_loop
                end
            end
        end

        def self.report(report_index)
            puts "Match Report Preamble for #{report_index}"
            puts Report.preamble(report_index)

            puts ""
            puts "Controls:"
            puts "Spacebar:     Show next report item."
            puts "e, q:         Exit back to report list menu. "
            puts ""

            input = ""
            while (!input.match(/[qe]/) && !Report.done)
                input = STDIN.getch

                if ' ' == input
                    blurb = Report.next_blurb
                    puts ""
                    puts "#{blurb.label}"
                    puts "#{blurb.text}"
                    puts ""
                end
            end

            if Report.done
                puts Report.conclusion
            end
        end

        def self.report_list(team_name)
            reports = Report.list(team_name)

            reports.each.with_index(1) do |report, index|
                puts "#{index}. #{report.team1} vs. #{report.team2}"
            end

            @@report_list_size = reports.size
            @@report_list_filter = team_name
            @@just_printed_report_list = true
        end

        def self.report_list_loop
            input = ""
            while (!input.match(/^e(xit)?\s*$/))
                print "REPORT LIST MENU: [report #] | Help  |  Exit: "

                input = gets.strip.downcase

                if input.to_i > 0
                    if input.to_i > @@report_list_size
                        puts "Invalid index. Please try again"
                    else
                        self.report(input.to_i)
                        self.report_list(@@report_list_filter)
                    end
                elsif input.match(/^h(elp)?\s*$/)
                    self.controls
                end
            end
        end

        def self.goodbye
            puts ""
            puts "Thanks for using this app. Goodbye!"
            puts ""
        end
    end
end
  