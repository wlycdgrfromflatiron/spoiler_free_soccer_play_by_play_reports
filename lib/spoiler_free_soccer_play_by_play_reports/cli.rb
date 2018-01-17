module SpoilerFreeSoccerPlayByPlayReports
    class CLI
        class InputHandler
            ###################
            # CLASS CONSTANTS #
            ###################
            INPUT_MATCHES = '(M)atches'
            INPUT_NEXT_BLURB = 'Next blurb'
            INPUT_REPORT_INDEX = '[report #]'
            INPUT_TEAM_INDEX = '[team #]'
            INPUT_TEAM_NAME = '[team name]'
            INPUT_TEAMS = '(T)eams'

            REGEX_MATCHES = /^m(atches)?\s*?/
            REGEX_QUIT = /^q(uit)?\s*$/
            REGEX_TEAMS = /^t(eams)?\s*?/


            ###################
            # CLASS VARIABLES #
            ###################
            @@input_prompt = "Default InputHandler input prompt: "


            ########################
            # PUBLIC CLASS METHODS #
            ########################
            def self.build_input_prompt(accepted_inputs)
                @@input_prompt = ""

                accepted_inputs.each do |accepted_input|
                    @@input_prompt << accepted_input << " | "
                end

                @@input_prompt << "(Q)uit: "
            end

            def self.handle_input(accepted_inputs)
                Printer.indented_print(@@input_prompt)
                input = gets.strip

                if input.match(REGEX_QUIT)
                    StatePlayer.stop
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
                if !Report.matches(team_name).empty?
                    StatePlayer.play(State::MATCHES_LIST)
                else
                    State.error_message = team_name ? 
                    "No matches are available for #{team_name} :(\n"\
                    "...However, the parser is not the brightest.\n"\
                    "You may want to double-check your spelling and/or try (T)eams just in case." : 
                    "No matches are currently available :("
                end
            end

            def self.handle_report_index_input(input_number)
                if input_number > Report.current_list.size
                    State.error_message = "Invalid report number! Please try again."
                else
                    CLI::report_index == input_number
                    StatePlayer.play(State::REPORT)
                end
            end

            def self.handle_team_index_input(input_number)
                if input_number > Report.teams.size
                    State.error_message = "Invalid index! Please try again."
                else
                    Report.matches(Reports.teams[input_number - 1])
                    StatePlayer.play(State::MATCHES_LIST)
                end
            end

            def self.handle_teams_input
                if !Report.teams.empty?
                    StatePlayer.play(State::TEAMS_LIST)
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
            MAIN_MENU = 0
            MATCHES_LIST = 1
            TEAMS_LIST = 2
            REPORT = 3

            ACCEPTED_INPUTS = [
                # MAIN_MENU
                [
                    InputHandler::INPUT_MATCHES, 
                    InputHandler::INPUT_TEAMS, 
                    InputHandler::INPUT_TEAM_NAME
                ], 

                # MATCHES_LIST
                [                
                    InputHandler::INPUT_REPORT_INDEX, 
                    InputHandler::INPUT_MATCHES, 
                    InputHandler::INPUT_TEAMS,
                    InputHandler::INPUT_TEAM_NAME
                ],

                # TEAMS_LIST
                [
                    InputHandler::INPUT_TEAM_INDEX,
                    InputHandler::INPUT_MATCHES
                ],

                # REPORT
                [
                    InputHandler::INPUT_NEXT_BLURB,
                    InputHandler::INPUT_MATCHES,
                    InputHandler::INPUT_TEAMS
                ]
            ]


            ###################
            # CLASS VARIABLES #
            ###################
            @@current_state = 1
            @@error_message = ""
            @@output_strings = []


            ########################
            # PUBLIC CLASS METHODS #
            ########################
            def self.error_message
                @@error_message
            end

            def self.error_message=(string)
                @@error_message = string
            end

            def self.id
                @@current_state
            end

            def self.set(id)
                @@current_state = id
                InputHandler.build_input_prompt(ACCEPTED_INPUTS[State.id])
            end

            def self.output_strings
                @@output_strings
            end

            def self.output_strings=(strings)
                @@output_strings = strings
            end

            def self.update
                Printer.clear_screen
                Printer.padded_puts(State.output_strings)
                Printer.padded_puts(State.error_message, true, true)
                InputHandler.handle_input(ACCEPTED_INPUTS[State.id])
            end
        end

        class StatePlayer
            @@keep_playing = true

            def self.play(state_id)
                self.load(state_id)

                while (@@keep_playing)
                    State.update
                end
            end

            def self.load(state_id)
                State.set(state_id)

                output_strings = []
                case State.id
                when State::MAIN_MENU
                    output_strings << CLI.welcome

                    controls_string = ""
                    controls_string << "MAIN MENU CONTROLS:\n"
                    controls_string << "(M)atches:        List all matches for which reports are available.\n"
                    controls_string << "(T)eams:          List all teams for which reports are available.\n"
                    controls_string << "[team name]:      List all available reports for [team name].\n"
                    controls_string << "(Q)uit:           Quit the program."
                    output_strings << controls_string

                when State::MATCHES_LIST
                    output_strings << (Report.current_team_name ?
                        "AVAILABLE REPORTS FOR #{Report.current_team_name}" :
                        "ALL AVAILABLE REPORTS")

                    output_strings << Printer.build_columnized_string_from_string_array(
                        Report.matches(Report.current_team_name).collect.with_index(1) do |match, index|
                            "#{index}. #{match.team1} vs. #{match.team2}"
                        end
                    )

                when State::TEAMS_LIST
                    output_strings << "TEAMS THAT HAVE REPORTS AVAILABLE:"

                    output_strings << Printer.build_columnized_string_from_string_array(
                        Report.teams.collect.with_index(1) do |team_name, index|
                            "#{index}. #{team_name}"
                        end
                    )

                when State::REPORT
                    output_string << "Report output string 1!"
                end
                State.output_strings = output_strings
            end

            def self.stop
                @@keep_playing = false
            end
        end

        @@report_index = nil

        # ENTRY POINT
        def self.start
            Printer.clear_screen
            Printer.padded_puts(self.welcome)
            Printer.padded_puts("Loading report list...")
            
            Report.list('all')

            StatePlayer.play(State::MAIN_MENU)

            Printer.padded_puts("Thanks for using this app. Goodbye!")
        end

        # REPORT LOOP
        def self.report_loop
            report = Report.report(@@report_index)

            system "clear" or system "cls"
            puts ""
            puts "MATCH REPORT\n".prepend(INDENT)
            puts "#{report.team1} VS. #{report.team2}\n".prepend(INDENT)
            puts ""
            puts "Author: #{report.byline.author}\n".prepend(INDENT)
            puts "Filed: #{report.byline.filed}\n".prepend(INDENT)
            puts "#{report.byline.updated}\n".prepend(INDENT)
            puts ""
            puts "Controls:\n".prepend(INDENT)
            puts "[Spacebar]:      Show next report item.\n".prepend(INDENT)
            puts "m:               List all available match reports.\n".prepend(INDENT)
            puts "t:               List all teams for which reports are available.\n".prepend(INDENT)
            puts "q:               Quit the program.\n".prepend(INDENT)
            puts ""

            blurb = nil
            while (STATE_REPORT == @@state && !Report.done)
                @@input = STDIN.getch

                if ' ' == @@input
                    blurb = Report.next_blurb
                    puts ""
                    puts "#{blurb.label}".prepend(INDENT)
                    puts ""
                    blurb.paragraphs.each do |paragraph|
                        puts paragraph.prepend(INDENT)
                        puts ""
                    end

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
            welcome_string << "~ SPOILER-FREE PLAY-BY-PLAY SOCCER MATCH REPORTS ~\n"
            welcome_string << "A service for reading live commentaries for completed soccer matches\n"
            welcome_string << "in chronological order and without spoilers.\n"
            welcome_string << "(data source: SPORTSMOLE.CO.UK)"
        end
    end
end