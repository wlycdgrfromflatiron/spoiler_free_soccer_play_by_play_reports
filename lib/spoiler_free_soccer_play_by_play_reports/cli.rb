module SpoilerFreeSoccerPlayByPlayReports
    class CLI
        extend WlyCuteConsole::ClassMethods

        class InputHandler
            INPUT_MATCHES = '(M)atches'
            INPUT_NEXT_BLURB = 'Next blurb'
            INPUT_REPORT_INDEX = '[report #]'
            INPUT_TEAM_INDEX = '[team #]'
            INPUT_TEAM_NAME = '[team name]'
            INPUT_TEAMS = '(T)eams'

            REGEX_MATCHES = /^m(atches)?\s*?/
            REGEX_QUIT = /^q(uit)?\s*$/
            REGEX_TEAMS = /^t(eams)?\s*?/

            @@error_feedback = ""

            @@input_prompt = "Default InputHandler input prompt: "

            def self.build_input_prompt(accepted_inputs)
                @@input_prompt = "Custom input prompt!!"
            end

            def self.handle_input(accepted_inputs)
                Printer.print(@@error_feedback)

                Printer.print(@@input_prompt)
                input = gets.strip

                if input.match(REGEX_QUIT)
                    StatePlayer.stop

                elsif input.to_i > 0
                    if accepted_inputs.include?(INPUT_REPORT_INDEX)
                        if input.to_i > Report.current_list.size
                            @@error_feedback = "Invalid report number! Please try again."
                        else
                            CLI::report_index == input.to_i
                            StatePlayer.play(State::REPORT)
                        end
                    end

                    elsif accepted_inputs.include?(INPUT_TEAM_INDEX)
                        if input.to_i > Report.teams.size
                            @@error_feedback = "Invalid index! Please try again."
                        else
                            Report.matches(Reports.teams[input.to_i - 1])
                            StatePlayer.play(State::MATCHES_LIST)
                        end

                elsif accepted_inputs.include?(INPUT_MATCHES) && input.match(REGEX_MATCHES)
                    self.handle_matches_input(nil)

                elsif accepted_inputs.include?(INPUT_TEAMS) && input.match(REGEX_TEAMS)
                    if !Report.teams.empty?
                        StatePlayer.play(State::TEAMS_LIST)
                    else 
                        @@error_feedback = "No reports are currently available for any teams :("
                    end

                elsif accepted_inputs.include?(INPUT_TEAM_NAME)
                    self.handle_matches_input(input)
                end
            end

            def self.handle_matches_input(team_name)
                if !Report.matches(team_name).empty?
                    StatePlayer.play(State::MATCHES_LIST)
                else
                    ## TODO factor out to Printer
                    @@error_feedback = team_name ? 
                    "No matches are available for #{team_name} :(\n"\
                    "...However, the parser is not the brightest.\n"\
                    "You may want to double-check your spelling and/or try (T)eams just in case." : 
                    "No matches are currently available :("
                end
            end
        end

        class State
            MAIN_MENU = 0
            MATCHES_LIST = 1
            TEAMS_LIST = 2
            REPORT = 3

            @@current_id = 1
            @@output_strings = []

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

            def self.id
                @@current_id
            end

            def self.id=(id)
                @@current_id = id
                InputHandler.build_input_prompt(ACCEPTED_INPUTS[@@current_id])
            end

            def self.output_strings=(strings)
                @@output_strings = strings
            end

            def self.update
                Printer.clear_screen
                Printer.line_feed
                Printer.print(@@output_strings)

                InputHandler.handle_input(ACCEPTED_INPUTS[@@current_id])
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
                State.id = state_id

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
                    output_strings << Report.current_team_name ?
                        "AVAILABLE REPORTS FOR #{Report.current_team_name.upcase}" :
                        "ALL AVAILABLE REPORTS"

                    output_strings << column_print(
                        Report.matches(Report.current_team_name).collect.with_index(1) do |match, index|
                            "#{index}. #{match.team1} vs. #{match.team2}"
                        end
                    )

                when State::TEAMS_LIST
                    output_string << "Teams list output string 1!"
=begin
                    header_string = "TEAMS THAT HAVE REPORTS AVAILABLE:".prepend(INDENT)

                    team_list_string = column_print(
                        Report.teams.collect.with_index(1) do |team_name, index|
                            "#{index}. #{team_name}"
                        end
                    )
=end
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
            Printer.line_feed
            Printer.print(self.welcome)
            Printer.line_feed
            Printer.print("Loading report list...")
            
            Report.list('all')

            StatePlayer.play(State::MAIN_MENU)

            Printer.line_feed
            Printer.print("Thanks for using this app. Goodbye!")
            Printer.line_feed
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