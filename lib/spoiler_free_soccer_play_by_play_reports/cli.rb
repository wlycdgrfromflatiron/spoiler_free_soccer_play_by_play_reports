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
        @@changing_state = false

        @@input = ""

        @@matches_list_team_name = nil
        @@report_index = nil

        @@error_string = nil

        # output formatting
        INDENT = "     "

        # regex strings
        REGEX_MATCHES = /^m(atches)?\s*?/
        REGEX_QUIT = /^q(uit)?\s*$/

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
                @@changing_state = false
                @@input = ""
            end
        end

        # STATE HANDLING
        def self.state(new_state)
            @@previous_state = @@state
            @@state = new_state
            @@changing_state = true
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

            while (!@@changing_state)
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

                elsif @@input.match(/^t(eams)?\s*?/)
                    if !Report.teams.empty?
                        self.state(STATE_TEAMS_LIST)
                    else
                        @@error_string = "No reports are currently available for any teams :("
                    end

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

            while (!@@changing_state)
                system "clear" or system "cls"
                puts ""
                puts header_string
                puts ""
                puts match_list_string 
                puts ""
                puts self.error_string
                puts ""

                print "[report #] | (B)ack | (Q)uit: ".prepend(INDENT)
                @@input = gets.chomp

                # User is trying to select a report to view
                if @@input.to_i > 0
                    if @@input.to_i > Report.matches(@@matches_list_team_name).size
                        @@error_string = "Invalid report number! Please try again."
                    else
                        @@report_index = @@input.to_i
                        self.state(STATE_REPORT)
                    end
                else 
                    self.handle_back_exit_and_misc
                end
            end
        end

        # TEAMS LIST LOOP
        def self.teams_list_loop
            header_string = "TEAMS THAT HAVE REPORTS AVAILABLE:".prepend(INDENT)

            teams_strings = []
            Report.teams.each.with_index(1) do |team_name, index|
                teams_strings << "#{index}. #{team_name}"
            end
            team_list_string = column_print(teams_strings)

            while (!@@changing_state)
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
            
            # Byline
            puts ""
            puts "MATCH REPORT".prepend(INDENT)
            puts "#{report.team1} VS. #{report.team2}".prepend(INDENT)
            puts ""
            puts "Author: #{report.byline.author}".prepend(INDENT)
            puts "Filed: #{report.byline.filed}".prepend(INDENT)
            puts "Updated: #{report.byline.updated}".prepend(INDENT)
            puts ""

            # Controls
            puts ""
            puts "Controls:".prepend(INDENT)
            puts "[Spacebar]:      Show next report item.".prepend(INDENT)
            puts "b:               Return to previous screen.".prepend(INDENT)
            puts "q:               Quit the program.".prepend(INDENT)
            puts ""

            blurb = nil
            while (!@@changing_state && !Report.done)
                @@input = STDIN.getch

                if ' ' == @@input
                    blurb = Report.next_blurb
                    puts ""
                    puts "#{blurb.label}".prepend(INDENT)
                    puts "#{blurb.text}".prepend(INDENT)
                    puts ""
                else
                    self.handle_back_exit_and_misc(false)
                end
            end

            if Report.done
                puts Report.conclusion.prepend(INDENT)
                STDIN.getch
            end
        end

        # PRINTER FUNCTIONS
        def self.error_string
            error_string = @@error_string ? @@error_string : ""
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
                    "No matches are available for #{@@input} :("\
                    "\n...However, the parser is not the brightest."\
                    "\nYou may want to double-check your spelling and/or try (T)eams just in case." : 
                    "No matches are currently available :("
            end
        end
    end
end