module SpoilerFreeSoccerPlayByPlayReports
    class CLI


        ##################
        # HELPER CLASSES #
        ##################
        class InputHandler


            ###################
            # CLASS CONSTANTS #
            ###################
            INPUT_MATCHES = '(M)atches'
            INPUT_NEXT_BLURB = '[Spacebar]'
            INPUT_REPORT_INDEX = '[report #]'
            INPUT_TEAM_INDEX = '[team #]'
            INPUT_TEAM_NAME = '[team name]'
            INPUT_TEAMS = '(T)eams'

            REGEX_MATCHES = /^m(atches)?\s*?/
            REGEX_NEXT_BLURB = / /
            REGEX_QUIT = /^q(uit)?\s*$/
            REGEX_TEAMS = /^t(eams)?\s*?/


            ###################
            # CLASS VARIABLES #
            ###################
            @@input_prompt = "Enter command or (Q)uit: "


            ########################
            # PUBLIC CLASS METHODS #
            ########################
            def self.build_input_prompt(accepted_inputs)
                @@input_prompt = ""
                accepted_inputs.each {|accepted_input| @@input_prompt << accepted_input << " | "}
                @@input_prompt << "(Q)uit: "
            end

            def self.handle_input(accepted_inputs)
                Printer.indented_print(@@input_prompt)
                input = gets.strip

                if input.match(REGEX_QUIT)
                    CLI.should_quit = true
                elsif input.to_i > 0
                    handle_integer_input(input.to_i, accepted_inputs)
                elsif accepted_inputs.include?(INPUT_MATCHES) && input.match(REGEX_MATCHES)
                    handle_matches_input(nil)
                elsif accepted_inputs.include?(INPUT_TEAMS) && input.match(REGEX_TEAMS)
                    handle_teams_input()
                elsif accepted_inputs.include?(INPUT_TEAM_NAME)
                    handle_matches_input(input)
                end
            end

            def self.handle_report_input(report)
                while (State::REPORT == State.screen && !CLI.should_quit && !Report.done)
                    input == STDIN.getch

                    if input.match(REGEX_QUIT)
                        CLI.should_quit = true
                    elsif input.match(REGEX_NEXT_BLURB)
                        handle_next_blurb_input()
                    elsif input.match(REGEX_MATCHES)
                        handle_matches_input(nil)
                    elsif input.match(REGEX_TEAMS)
                        handle_teams_input()
                    end
                end

                if Report.done
                    Printer.indented_print(Report.conclusion.prepend(INDENT))
                    STDIN.getch
                end
            end

            #########################
            # PRIVATE CLASS METHODS #
            #########################
            def self.handle_integer_input(input_number, accepted_inputs)
                if accepted_inputs.include?(INPUT_REPORT_INDEX)
                    handle_report_index_input(input_number)
                elsif accepted_inputs.include?(INPUT_TEAM_INDEX)
                    handle_teams_index_input(input_number)
                end
            end

            def self.handle_matches_input(team_name)
                CLI.selected_team = team_name

                if !Report.matches(CLI.selected_team).empty?
                    State.screen = State::TO_MATCHES_LIST
                else
                    State.error_message = team_name ? 
                    "No matches are available for #{CLI.selected_team} :(\n"\
                    "...However, the parser is not the brightest.\n"\
                    "You may want to double-check your spelling and/or try (T)eams just in case." : 
                    "No matches are currently available :("
                end
            end

            def self.handle_next_blurb_input
                blurb = Report.next_blurb

                puts ""
                Printer.print_indented("#{blurb.label}\n")
                blurb.paragraphs.each do |paragraph|
                    Printer.print_indented(paragraph)
                end
            end

            def self.handle_report_index_input(input_number)
                if input_number > Report.current_list.size
                    State.error_message = "Invalid report number! Please try again."
                else
                    CLI.report_index == input_number
                    State.screen = State::REPORT
                end
            end

            def self.handle_team_index_input(input_number)
                if input_number > Report.teams.size
                    State.error_message = "Invalid index! Please try again."
                else
                    Report.matches(Reports.teams[input_number - 1])
                    State.screen = State::MATCHES_LIST
                end
            end

            def self.handle_teams_input
                if !Report.teams.empty?
                    State.screen = State::TEAMS_LIST
                else 
                    State.error_message = "No reports are currently available for any teams :("
                end
            end

            private_class_method :handle_integer_input, :handle_matches_input, 
            :handle_report_index_input, :handle_team_index_input, :handle_teams_input
        end


        class State
            ###################
            # CLASS CONSTANTS #
            ###################
            LOADING = 0
            MAIN_MENU = 1
            MATCHES_LIST = 2
            REPORT = 3
            TEAMS_LIST = 4
            TO_MAIN_MENU = 5
            TO_MATCHES_LIST = 6
            TO_REPORT = 7
            TO_TEAMS_LIST = 8

            ACCEPTED_INPUTS = [
                [ # MAIN_MENU
                    InputHandler::INPUT_MATCHES, 
                    InputHandler::INPUT_TEAMS, 
                    InputHandler::INPUT_TEAM_NAME
                ], 
                [  # MATCHES_LIST              
                    InputHandler::INPUT_REPORT_INDEX, 
                    InputHandler::INPUT_MATCHES, 
                    InputHandler::INPUT_TEAMS,
                    InputHandler::INPUT_TEAM_NAME
                ],
                [ # TEAMS_LIST
                    InputHandler::INPUT_TEAM_INDEX,
                    InputHandler::INPUT_MATCHES
                ]
            ]

            ###################
            # CLASS VARIABLES #
            ###################
            @@current_screen = 1


            ########################
            # PUBLIC CLASS METHODS #
            ########################
            def self.screen
                @@current_screen
            end

            def self.screen=(name)
                @@current_screen = name
            end
        end


        #######################
        # CLI CLASS VARIABLES #
        #######################
        @@report_index = nil
        @@should_quit = false
        @@header_string = nil
        @@data_string = nil
        @@selected_team = nil


        ############################
        # CLI PUBLIC CLASS METHODS #
        ############################
        def self.data
            @@data_string
        end

        def self.data=(string)
            @@data_string = string
        end

        def self.header
            @@self_header
        end
        def self.header=(string)
            @@self_header = string
        end

        def self.main_menu_controls
            controls_string = ""
            controls_string << "MAIN MENU CONTROLS:\n"
            controls_string << "(M)atches:        List all matches for which reports are available.\n"
            controls_string << "(T)eams:          List all teams for which reports are available.\n"
            controls_string << "[team name]:      List all available reports for [team name].\n"
            controls_string << "(Q)uit:           Quit the program."
        end

        def self.welcome
            welcome_string = ""
            welcome_string << "~ SPOILER-FREE PLAY-BY-PLAY SOCCER MATCH REPORTS ~\n"
            welcome_string << "A service for reading live commentaries for completed soccer matches\n"
            welcome_string << "in chronological order and without spoilers.\n"
            welcome_string << "(data source: SPORTSMOLE.CO.UK)"
        end


# ----> ###############
# ----> # ENTRY POINT #
# ----> ###############
        def self.start
            State.screen = State::LOADING
            while (!@@should_quit)
                case State.screen
                when State::LOADING
                    Printer.clear_screen
                    Printer.line_feed
                    Printer.indented_puts(self.welcome)
                    Printer.line_feed
                    Printer.indented_puts("Loading report list...")
                    Report.list('all')
                    State.screen = State::TO_MAIN_MENU

                when State::TO_MAIN_MENU
                    self.header = self.welcome
                    self.data = self.main_menu_controls
                    InputHandler.build_input_prompt(State::ACCEPTED_INPUTS[State::MAIN_MENU])
                    State.screen = State::MAIN_MENU

                when State::MAIN_MENU, State::MATCHES_LIST, State::TEAMS_LIST
                    Printer.clear_screen
                    Printer.indented_puts(self.header)
                    Printer.indented_puts(self.data)
                    Printer.indented_puts(self.error_message)
                    InputHandler.handle_input(State::ACCEPTED_INPUTS[State.screen])

                when State::TO_MATCHES_LIST
                    self.header = (self.selected_team ?
                        "AVAILABLE REPORTS FOR #{self.selected_team}" :
                        "ALL AVAILABLE REPORTS")
                    self.data =  Printer.build_columnized_string_from_string_array(
                        Report.matches(self.selected_team).collect.with_index(1) do |match, index|
                            "#{index}. #{match.team1} vs. #{match.team2}"
                        end
                    )
                    InputHandler.build_input_prompt(State::ACCEPTED_INPUTS[State::MATCHES_LIST])
                    State.screen = State::MATCHES_LIST
                
                when State::TO_TEAMS_LIST
                    self.header = "TEAMS THAT HAVE REPORTS AVAILABLE:"
                    self.data = Printer.build_columnized_string_from_string_array(
                        Report.teams.collect.with_index(1) do |team_name, index|
                            "#{index}. #{team_name}"
                        end
                    )
                    InputHandler.build_input_prompt(State::ACCEPTED_INPUTS[State::TEAMS_LIST])
                    State.screen = State::TEAMS_LIST

                when State::TO_REPORT
                    @@report = Report.report(CLI.report_index)

                    Printer.clear_screen
                    Printer.line_feed
                    Printer.indented_puts("MATCH REPORT")
                    Printer.indented_puts("#{@@report.team1} VS. #{@@report.team2}")
                    Printer.line_feed
    
                    Printer.indented_puts("Author: #{@@report.byline.author}")
                    Printer.indented_puts("Filed: #{@@report.byline.filed}")
                    Printer.indented_puts("#report.byline.updated")
                    Printer.line_feed
    
                    Printer.indented_puts("Controls:")
                    Printer.indented_puts("[Spacebar]:      Show next report item.")
                    Printer.indented_puts("m:               List all available match reports.")
                    Printer.indented_puts("t:               List all teams for which reports are available.")
                    Printer.indented_puts("q:               Quit the program.")
                    Printer.line_feed

                    State.screen = State::REPORT

                when State::REPORT
                    InputHandler.handle_report_input
                end
            end # main while loop

            Printer.indented_puts("Thanks for using this app. Goodbye!")
        end # CLI.start
    end # class CLI
end # module SpoilerFreeSoccerPlayByPlayReports