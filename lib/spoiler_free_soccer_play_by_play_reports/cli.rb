module SpoilerFreeSoccerPlayByPlayReports
    class CLI
        extend WlyCuteConsole::ClassMethods

        # state tracking
        STATE_MAIN_MENU = 1
        STATE_MATCHES_LIST = 2
        STATE_TEAMS_LIST = 3
        STATE_REPORT = 4
        STATE_QUIT = 5

        @@state = nil

        @@input = ""

        @@matches_list_team_name = nil
        @@report_index = nil

        # output formatting
        INDENT = "     "

        # error handling
        @@error_string = nil

        # regex strings
        REGEX_MATCHES = /^m(atches)?\s*?/
        REGEX_QUIT = /^q(uit)?\s*$/
        REGEX_TEAMS = /^t(eams)?\s*?/

        # ENTRY POINT
        def self.start
            system "clear" or system "cls"
            puts ""
            puts self.welcome
            puts ""
            puts "Loading report list...".prepend(INDENT)
            Report.list('all')

            self.state(STATE_MAIN_MENU)
            self.main_loop

            puts ""
            puts "Thanks for using this app. Goodbye!".prepend(INDENT)
            puts ""
        end

        # MAIN LOOP
        def self.main_loop
            while STATE_QUIT != @@state
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
                @@input = ""
            end
        end

        # STATE HANDLING
        def self.state(new_state)
            @@previous_state = @@state
            @@state = new_state
        end

        # MAIN MENU LOOP AND ITS HELPER FUNCTIONS
        def self.main_menu_loop
            welcome_string = self.welcome
            controls_string = ""
            controls_string << "MAIN MENU CONTROLS:\n".prepend(INDENT)
            controls_string << "(M)atches:        List all matches for which reports are available.\n".prepend(INDENT)
            controls_string << "(T)eams:          List all teams for which reports are available.\n".prepend(INDENT)
            controls_string << "[team name]:      List all available reports for [team name].\n".prepend(INDENT)
            controls_string << "(Q)uit:           Quit the program.".prepend(INDENT)

            while (STATE_MAIN_MENU == @@state)
                system "clear" or system "cls"
                puts ""
                puts welcome_string
                puts ""
                puts controls_string
                puts ""
                puts self.error_string
                puts ""
            
                print "(M)atches | (T)eams | [team name] | (Q)uit: ".prepend(INDENT)
                @@input = gets.strip

                if @@input.match(REGEX_QUIT) 
                    self.state(STATE_QUIT)

                elsif @@input.match(REGEX_MATCHES) 
                    self.handle_matches_input(nil)

                elsif @@input.match(REGEX_TEAMS)
                    self.handle_teams_input

                else
                    self.handle_matches_input(@@input)
                end
            end
        end

        # MATCHES LIST LOOP
        def self.matches_list_loop
            header_string = @@matches_list_team_name ? 
                "AVAILABLE REPORTS FOR #{@@matches_list_team_name.upcase}".prepend(INDENT) : 
                "ALL AVAILABLE REPORTS".prepend(INDENT)

            match_list_string = column_print(
                Report.matches(@@matches_list_team_name).collect.with_index(1) do |match, index|
                    "#{index}. #{match.team1} vs. #{match.team2}"
                end
            )

            input_prompt_string = "[report #] | ".prepend(INDENT)
            input_prompt_string << (@@matches_list_team_name ? "all (M)atches | " : "")
            input_prompt_string << "(T)eams | [team name] | (Q)uit: "

            while (STATE_MATCHES_LIST == @@state)
                system "clear" or system "cls"
                puts ""
                puts header_string
                puts ""
                puts match_list_string 
                puts ""
                puts self.error_string
                puts ""

                print input_prompt_string
                @@input = gets.chomp

                # User is trying to select a report to view
                if @@input.to_i > 0
                    if @@input.to_i > Report.matches(@@matches_list_team_name).size
                        @@error_string = "Invalid report number! Please try again."
                    else
                        @@report_index = @@input.to_i
                        self.state(STATE_REPORT)
                    end

                elsif @@input.match(REGEX_TEAMS)
                    self.handle_teams_input

                elsif @@matches_list_team_name && @@input.match(REGEX_MATCHES)
                    @@matches_list_team_name = nil
                    self.matches_list_loop

                elsif @@input.match(REGEX_QUIT)
                    self.state(STATE_QUIT)

                else 
                    if !Report.matches(@@input).empty?
                        @@matches_list_team_name = @@input
                        self.matches_list_loop
                    else
                        @@error_string = "No matches are available for #{@@input} :(\n"\
                        "#{INDENT}...However, the parser is not the brightest.\n"\
                        "#{INDENT}You may want to double-check your spelling and/or try (T)eams just in case."
                    end
                end
            end
        end

        # TEAMS LIST LOOP
        def self.teams_list_loop
            header_string = "TEAMS THAT HAVE REPORTS AVAILABLE:".prepend(INDENT)

            team_list_string = column_print(
                Report.teams.collect.with_index(1) do |team_name, index|
                    "#{index}. #{team_name}"
                end
            )

            while (STATE_TEAMS_LIST == @@state)
                system "clear" or system "cls"
                puts ""
                puts header_string
                puts ""
                puts team_list_string
                puts ""
                puts self.error_string
                puts ""

                print "[team #] | (M)atches | (Q)uit: ".prepend(INDENT)
                @@input = gets.chomp

                if @@input.to_i > 0
                    if @@input.to_i > Report.teams.size
                        @@error_string = "Invalid index! Please try again."
                    else
                        @@matches_list_team_name = Report.teams[@@input.to_i - 1]
                        self.state(STATE_MATCHES_LIST)
                    end
                elsif @@input.match(REGEX_MATCHES)
                    self.handle_matches_input(nil)
                elsif @@input.match(REGEX_QUIT)
                    self.state(STATE_QUIT)
                else
                    @@error_string = "To make a selection, enter its number."
                end
            end
        end

        # REPORT LOOP
        def self.report_loop
            report = Report.report(@@report_index)

            system "clear" or system "cls"
            
            # Byline
            byline_string = ""
            byline_string << "MATCH REPORT\n".prepend(INDENT)
            byline_string << "#{report.team1} VS. #{report.team2}\n".prepend(INDENT)
            byline_string << "\n"
            byline_string << "Author: #{report.byline.author}\n".prepend(INDENT)
            byline_string << "Filed: #{report.byline.filed}\n".prepend(INDENT)
            byline_string << "#{report.byline.updated}\n".prepend(INDENT)
            puts ""
            puts byline_string
            puts "" 

            # Controls
            puts ""
            puts "Controls:".prepend(INDENT)
            puts "[Spacebar]:      Show next report item.".prepend(INDENT)
            puts "m:               List all available match reports.".prepend(INDENT)
            puts "t:               List all teams for which reports are available.".prepend(INDENT)
            puts "q:               Quit the program.".prepend(INDENT)
            puts ""

            blurb = nil
            while (STATE_REPORT == @@state && !Report.done)
                @@input = STDIN.getch

                if ' ' == @@input
                    blurb = Report.next_blurb
                    puts ""
                    puts "#{blurb.label}".prepend(INDENT)
                    puts "#{blurb.text}".prepend(INDENT)
                    puts ""

                elsif @@input.match(REGEX_MATCHES)
                    self.handle_matches_input(nil)

                elsif @@input.match(REGEX_TEAMS)
                    self.handle_teams_input

                elsif @@input.match(REGEX_QUIT)
                    self.state(STATE_QUIT)
                end
            end

            if Report.done
                puts Report.conclusion.prepend(INDENT)
                STDIN.getch
            end
        end

        # PRINTER FUNCTIONS
        def self.error_string
            error_string = @@error_string ? @@error_string.prepend(INDENT) : ""
            @@error_string = nil
            error_string
        end

        def self.welcome
            welcome_string = ""
            welcome_string << "~ SPOILER-FREE PLAY-BY-PLAY SOCCER MATCH REPORTS ~\n".prepend(INDENT)
            welcome_string << "A service for reading live commentaries for completed soccer matches\n".prepend(INDENT)
            welcome_string << "in chronological order and without spoilers.\n".prepend(INDENT)
            welcome_string << "(data source: SPORTSMOLE.CO.UK)".prepend(INDENT)
        end

        # INPUT HANDLING
        def self.handle_back_exit_and_misc(handle_other=true)
            if @@input.match(/^b(ack)?\s*$/)
                self.state(@@previous_state)
            elsif @@input.match(REGEX_QUIT)
                self.state(STATE_QUIT)
            elsif handle_other
                @@error_string = "To make a selection, enter its number."
            end
        end

        def self.handle_matches_input(team_name)
            if !Report.matches(team_name).empty?
                self.state(STATE_MATCHES_LIST)
                @@matches_list_team_name = team_name
            else
                @@error_string = team_name ? 
                "No matches are available for #{@@input} :(\n"\
                "#{INDENT}...However, the parser is not the brightest.\n"\
                "#{INDENT}You may want to double-check your spelling and/or try (T)eams just in case." : 
                "No matches are currently available :("
            end
        end

        def self.handle_teams_input
            if !Report.teams.empty?
                self.state(STATE_TEAMS_LIST)
            else
                @@error_string = "No reports are currently available for any teams :("
            end
        end
    end
end