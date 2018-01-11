module SpoilerFreeSoccerPlayByPlayReports
    class CLI
        extend WlyCuteConsole::ClassMethods

        DEFAULT_PUTS_INDENT = 5
        DEFAULT_PRINT_INDENT = 5

        @@should_exit_program = false

        @@report_list_size = -1
        @@report_list_filter = "all"

        def self.start
            set_default_puts_indent(DEFAULT_PUTS_INDENT)
            set_default_print_indent(DEFAULT_PRINT_INDENT)

            system "clear" or system "cls"

            self.welcome 

            self.loading
            Report.list('all')
            self.done_loading

            self.controls

            self.main_loop

            self.goodbye
        end

        def self.loading
            puts_indented("Loading report list...")
        end

        def self.done_loading
            puts_indented("...Done")
        end

        def self.welcome
            puts "" 
            puts_indented("~ Welcome Spoiler Free Soccer Play by Play Reports ~")
            puts_indented("(data provided by Sportsmole)")
            puts "" 
        end

        def self.controls
            puts ""
            puts_indented("Controls:")
            puts_indented("All:          List all available reports.")
            puts_indented("[team name]:  List all available reports involving [team name].")
            puts_indented("[report #]:   View the corresponding report (available after printing a report list).")
            puts_indented("[Spacebar]:   Show next report item (available on report detail screen).")
            puts_indented("Help:         See these instructions.")
            puts_indented("Exit, 'Quit': Quit back to previous menu. If in main menu, quit.")
            puts ""
        end

        def self.main_loop
            input = ""

            while (!@@should_exit_program)
                print_indented "MAIN MENU: All | [team name] |  Help  | Exit: "
                
                input = gets.strip.downcase

                case input
                when /^a(ll)?\s*$/
                    self.report_list('all')
                when /^h(elp)?\s*$/
                    self.controls
                when /^e(xit)?\s*$/, "", /^\s*$/
                    @@should_exit_program = true
                else
                    self.report_list(input)
                end
            end
        end

        def self.report(report_index)
            self.report_preamble(Report.report(report_index))

            puts ""
            puts_indented("Controls:")
            puts_indented("Spacebar:     Show next report item.")
            puts_indented("e, q:         Exit back to report list menu. ")
            puts ""

            input = ""
            while (!input.match(/[qe]/) && !Report.done)
                input = STDIN.getch

                if ' ' == input
                    blurb = Report.next_blurb
                    puts ""
                    puts_indented("#{blurb.label}")
                    puts_indented("#{blurb.text}")
                    puts ""
                end
            end

            if Report.done
                puts Report.conclusion
            end
        end

        def self.report_preamble(report)
            puts ""
            puts_indented("MATCH REPORT")
            puts_indented("#{report.team1} VS. #{report.team2}")
            puts_indented("")
            puts_indented("Author: #{report.byline.author}")
            puts_indented("Filed: #{report.byline.filed}")
            puts_indented("Updated: #{report.byline.updated}")
            puts ""
        end

        def self.report_list(team_name)
            reports = Report.list(team_name)

            if (reports.size > 0)
                self.report_list_loop(reports, team_name)
            else
                puts ""
                puts_indented("There are no reports available for a team called #{team_name}.")
                puts_indented("However, the matcher is literal and (aside from being case-insensitive) stupid,")
                puts_indented("so please double check your spelling, and/or use 'all' to list all reports just in case.")
                puts ""
            end
        end

        def self.report_list_loop(reports, team_name)
            input = ""

            info_readout = ""

            should_return_to_team_list = false
            while (!should_return_to_team_list)
                system "clear" or system "cls"

                puts ""
                puts_indented("AVAILABLE REPORTS FOR #{team_name}")
                puts ""

                reports.each.with_index(1) do |report, index|
                    puts_indented("#{index}. #{report.team1} vs. #{report.team2}")
                end

                if !info_readout.empty?
                    puts ""
                    "controls" == info_readout ? self.controls : puts_indented(info_readout)
                end
                
                info_readout = info_readout.clear

                puts ""
                print_indented("REPORT LIST MENU: [report #] | Back to team list | Help | Exit: ")

                input = gets.strip.downcase

                if input.to_i > 0
                    if input.to_i > reports.size
                        info_readout = "Invalid report number! Please try again."
                    else
                        self.report(input.to_i)
                    end
                elsif input.match(/^b(ack)?\s*$/)
                    should_return_to_team_list = true
                elsif input.match(/^h(elp)?\s*$/)
                    info_readout = "controls"
                elsif input.match(/^e(xit)?\s*$/)
                    should_return_to_team_list = true
                    @@should_exit_program = true
                else
                    info_readout = "To view a report, please enter its number."
                end
            end
        end

        def self.goodbye
            puts ""
            puts_indented("Thanks for using this app. Goodbye!")
            puts ""
        end
    end
end
  