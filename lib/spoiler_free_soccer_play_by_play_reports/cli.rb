module SpoilerFreeSoccerPlayByPlayReports
    class CLI
        extend WlyCuteConsole::ClassMethods

        # state tracking
        STATE_MAIN_MENU = 1
        STATE_MATCHES_LIST = 2
        STATE_TEAMS_LIST = 3
        STATE_REPORT = 4
        @@state = nil

        @@should_exit = false

        @@matches_list = []
        @@matches_list_team_name = nil
        @@teams_list = []
        @@report_index = nil

        @@error_message = nil

        # output formatting
        PUTS_INDENT = 5
        PRINT_INDENT = 5

        def self.start
            set_default_puts_indent(PUTS_INDENT)
            set_default_print_indent(PRINT_INDENT)

            system "clear" or system "cls"

            puts ""; self.welcome; puts ""
            puts_indented("Loading report list...")
            Report.list('all')

            @@state = STATE_MAIN_MENU
            @@previous_state = nil
            self.main_loop

            self.goodbye
        end

        def self.welcome
            puts_indented("~ SPOILER-FREE PLAY-BY-PLAY SOCCER MATCH REPORTS ~")
            puts_indented("A service for reading live commentaries for completed soccer matches")
            puts_indented("in chronological order and without spoilers.")
            puts_indented("(data source: SPORTSMOLE.CO.UK)")
        end

        def self.main_menu_controls
            puts_indented("MAIN MENU CONTROLS:")
            puts_indented("(M)atches:        List all matches for which reports are available.")
            puts_indented("(T)eams:          List all teams for which reports are available.")
            puts_indented("[team name]:      List all available reports for [team name].")
            puts_indented("(E)xit:           Exit the program.")
        end

        def self.error_message
            puts_indented(@@error_message) if @error_message
            @@error_message = nil
        end

        def self.state(new_state)
            @@previous_state = @@state
            @@state = new_state
        end

        def self.main_loop
            while !@@should_exit
                case @@state
                when STATE_MAIN_MENU
                    self.main_menu_loop
                when STATE_MATCHES_LIST
                    self.matches_list_loop
                when STATE_TEAMS_LIST
                    self.teams_list_loop
                when STATE_REPORT
                    self.report_loop
                end
            end
        end

        def self.main_menu_loop
            in_this_state = true
            input = ""

            while (in_this_state)
                system "clear" or system "cls"

                puts ""
                self.welcome
                puts ""
                self.main_menu_controls
                puts ""
                self.error_message
            
                print_indented("(M)atches | (T)eams | [team name] | (E)xit: ")
                input = gets.strip

                # User wants to quit
                if input.match(/^e(xit)?\s*$/)
                    @@should_exit = true
                    in_this_state = false

                # User wants to see a list of all matches
                elsif input.match(/^m(atches)?\s*?/)
                    @@matches_list = Report.matches
                    if !@@matches_list.empty?
                        self.state(STATE_MATCHES_LIST)
                        in_this_state = false
                    else
                        @@error_message = "No matches are currently available :("
                    end

                # User wants to see a list of all teams
                elsif input.match(/^t(eams)?\s*?/)
                    @@teams_list = Report.teams
                    if !@@teams_list.empty?
                        self.state(STATE_TEAMS_LIST)
                        in_this_state = false
                    else
                        @@error_message = "No reports are currently available for any teams :("
                    end

                # Or, user is trying to enter a team name...probably... - 
                # but since any old gibberish COULD be a team name that we forgot or didn't know about,
                # let's not risk filtering out what could be a valid search - 
                # let's just trust the user and see if there are any matching reports for whatever they entered.
                # If user is trolling, we just won't get any results, no big deal.
                # (Heh, no doubt there's some terrible security hole I'm leaving open...)
                else
                    @@matches_list = Report.matches
                    if !@@matches_list.empty?
                        @@matches_list_team_name = input

                        self.state(STATE_MATCHES_LIST)
                        in_this_state = false
                    else
                        @@error_message = "No matches are available for #{team_name} :("\
                            "\n...However, the parser is not the brightest."\
                            "\nYou may want to double-check your spelling and/or try (T)eams just in case."
                    end
                end
            end
        end

        def self.matches_list_loop
            in_this_state = true
            input = ""

            header = @@matches_list_team_name ? 
                "AVAILABLE REPORTS FOR #{@@matches_list_team_name.upcase}" : 
                "ALL AVAILABLE REPORTS"

            match_strings = []
            @@matches_list.each.with_index(1) do |match, index|
                match_strings << "#{index}. #{match.team1} vs. #{match.team2}"
            end
            match_list_string = column_print(match_strings)

            while (in_this_state)
                system "clear" or system "cls"

                puts ""
                puts_indented(header)
                puts ""

                puts match_list_string
                puts ""

                self.error_message

                print_indented("[report #] | (B)ack | (E)xit: ")
                input = gets.chomp

                # User is trying to select a report to view
                if input.to_i > 0
                    if input.to_i > @@matches_list.size
                        @@error_message = "Invalid report number! Please try again."
                    else
                        @@report_index = input.to_i

                        self.state(STATE_REPORT)
                        in_this_state = false
                    end
                else 
                    in_this_state = self.handle_back_exit_and_misc(input)
                end
            end
        end

        def self.teams_list_loop
            in_this_state = true
            input = ""

            while (in_this_state)
                system "clear" or system "cls"

                puts ""
                puts_indented("TEAMS THAT HAVE REPORTS AVAILABLE:")
                puts ""

                @@teams_list.each.with_index(1) do |team_name, index|
                    puts_indented("#{index}. #{team_name}")
                end

                self.error_message

                print_indented("[team #] | (B)ack | (E)xit: ")
                input = gets.chomp

                # User is trying to select a team to see a list of available matches for
                if input.to_i > 0
                    if input.to_i > @@teams_list.size
                        @@error_message = "Invalid index! Please try again."
                    else
                        team_name = @@teams_list[input.to_i - 1]
                        @@matches_list = Report.matches(team_name)
                        @@matches_list_team_name = team_name

                        self.state(STATE_MATCHES_LIST)
                        in_this_state = false
                    end
                else 
                    in_this_state = self.handle_back_exit_and_misc(input)
                end
            end
        end

        def self.handle_back_exit_and_misc(input)
            in_this_state = true 

            # User is trying to return to previous screen
            if input.match(/^b(ack)?\s*$/)
                self.state(@@previous_state)
                in_this_state = false

            # User is trying to exit the program
            elsif input.match(/^e(xit)?\s*$/)
                @@should_exit = true
                in_this_state = false

            # User has entered some funsense
            else
                @@error_message = "To make a selection, enter its number."
            end

            in_this_state
        end

        def self.report_loop
            report = Report.report(@@report_index)
            
            self.report_preamble(report)

            puts ""
            puts_indented("Controls:")
            puts_indented("[Spacebar]:      Show next report item.")
            puts_indented("b:               Return to previous screen.")
            puts_indented("q:               Exit the program.")
            puts ""

            in_this_state = true
            input = ""
            while (in_this_state !input.match(/[qe]/) && !Report.done)
                input = STDIN.getch

                # User wants to see the next blurb
                if ' ' == input
                    blurb = Report.next_blurb
                    puts ""
                    puts_indented("#{blurb.label}")
                    puts_indented("#{blurb.text}")
                    puts ""
                
                # User wants to go back to the previous screen
                elsif input.match(/[bB]/)
                    this.state(@@previous_state)
                    in_this_state = false 

                # User wants to quit the program
                elsif input.match(/[qQ]/)
                    @@should_exit = true
                    in_this_state = false
                end

                if Report.done
                    puts Report.conclusion
                    in_this_state = false
                end
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

        def self.goodbye
            puts ""
            puts_indented("Thanks for using this app. Goodbye!")
            puts ""
        end
    end
end