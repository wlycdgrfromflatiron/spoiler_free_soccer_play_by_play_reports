module SpoilerFreeSoccerPlayByPlayReports
    class CLI
        extend WlyCuteConsole::ClassMethods

        class Printer
            INDENT = "     "

            def self.clear_print(string)
                system "clear" or system "cls"
                puts ""
                puts string
                puts ""
            end

            def print(string)
                puts ""
                puts string
                puts ""
            end
        end

        class InputHandler
            INPUT_MATCHES = '(M)atches'
            INPUT_REPORT_INDEX = '[report #]'
            INPUT_TEAMNAME = '[team name]'
            INPUT_TEAMS = '(T)eams'

            REGEX_MATCHES = /^m(atches)?\s*?/
            REGEX_QUIT = /^q(uit)?\s*$/
            REGEX_TEAMS = /^t(eams)?\s*?/

            @@error_feedback = ""

            @@input_prompt = "Default InputHandler input prompt: "

            def self.build_input_prompt(accepted_inputs)
                
            end

            def self.handle_input(options)
                Printer.print(@error_feedback)

                Printer.print(@input_prompt)
                input = gets.strip

                if input.match(REGEX_QUIT)
                    State.set_state(State::QUIT)

                elsif accepted_inputs.include?(INPUT_REPORT_INDEX) && input.to_i > 0
                    if input.to_i > Report.current_list.size
                        @@error_feedback = "Invalid report number! Please try again."
                    else
                        CLI::report_index == input.to_i
                        StatePlayer.play(State::REPORT)
                    end

                elsif accepted_inputs.include?(INPUT_MATCHES) && input.match(REGEX_MATCHES)
                    self.handle_matches_input(nil)

                elsif accepted_inputs.include?(INPUT_TEAMS) && input.match(REGEX_TEAMS)
                    if !Report.teams.empty?
                        StatePlayer.play(State::TEAMS_LIST)
                    else 
                        @@error_feedback = "No reports are currently available for any teams :("

                elsif accepted_inputs.include?(INPUT_TEAMNAME)
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
            MAIN_MENU = 1
            MATCHES_LIST = 2
            TEAMS_LIST = 3
            REPORT = 4

# Teams list
=begin
            header_string = "TEAMS THAT HAVE REPORTS AVAILABLE:".prepend(INDENT)

            team_list_string = column_print(
                Report.teams.collect.with_index(1) do |team_name, index|
                    "#{index}. #{team_name}"
                end
            )
=end

            INPUT_OPTIONS[MAIN_MENU] = [
                InputHandler::CLI_OPTION_MATCHES, 
                InputHandler::CLI_OPTION_TEAMS, 
                InputHandler::CLI_OPTION_TEAMNAME
            ]

            INPUT_OPTIONS[MATCHES_LIST] = [
                InputHandler::CLI_OPTION_REPORT_INDEX, 
                InputHandler::CLI_OPTION_MATCHES, 
                InputHanlder::CLI_OPTION_TEAMS,
                InputHandler::CLI_OPTION_TEAMNAME
            ]

            INPUT_OPTIONS[TEAMS_LIST] = [
                InputHandler::CLI_OPTION_TEAM_INDEX,
                InputHandler::CLI_OPTION_MATCHES
            ]

            INPUT_OPTIONS[REPORT] = [
                InputHandler::CLI_OPTION_NEXT_BLURB,
                InputHandler::CLI_OPTION_MATCHES,
                InputHandler::CLI_OPTION_TEAMS
            ]

            def initialize(id, input_options)
                @id = id
                @output_strings = ["Default output_string value for State #{@id}."]
            end

            def output_strings=(strings)
                @output_strings = strings
            end

            def update
                Printer.clear_print(@output_string)
                InputHandler.handle_input(INPUT_OPTIONS[@id])
            end
        end

        class StatePlayer
            @@current_state = nil
            @@states = []
            @@keep_playing = true

            def self.turn_on
                @@states << State.new(State::MAIN_MENU)
                @@states << State.new(State::MATCHES_LIST)
                @@states << State.new(State::TEAMS_LIST)
                @@states << State.new(State::REPORT)
            end

            def self.play(state)
                self.load(state)

                while (@@keep_playing)
                    @@current_state.update
                end
            end

            def self.load(state)
                @@current_state = @@states.detect {|state| state.id == state}

                output_strings = []
                case @@current_state
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
                    output_string << "Matches list output string 1!"

                    header_string = @@matches_list_team_name ? 
                    "AVAILABLE REPORTS FOR #{@@matches_list_team_name.upcase}".prepend(INDENT) : 
                    "ALL AVAILABLE REPORTS".prepend(INDENT)
    
                match_list_string = column_print(
                    Report.matches(@@matches_list_team_name).collect.with_index(1) do |match, index|
                        "#{index}. #{match.team1} vs. #{match.team2}"
                    end
                )

                when State::TEAMS_LIST
                    output_string << "Teams list output string 1!"

                when State::REPORT
                    output_string << "Report output string 1!"
                end
                @@current_state.output_strings = output_strings
            end

            def self.stop
                @@keep_playing = false
            end
        end

        @@report_index = nil

        # ENTRY POINT
        def self.start
            system "clear" or system "cls"
            puts ""
            puts self.welcome
            puts ""
            puts "Loading report list...".prepend(INDENT)
            Report.list('all')

            StatePlayer.turn_on
            StatePlayer.play(State::MAIN_MENU)

            puts ""
            puts "Thanks for using this app. Goodbye!".prepend(INDENT)
            puts ""
        end

        # TEAMS LIST LOOP
        def self.teams_list_loop

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
            welcome_string << "~ SPOILER-FREE PLAY-BY-PLAY SOCCER MATCH REPORTS ~\n".prepend(INDENT)
            welcome_string << "A service for reading live commentaries for completed soccer matches\n".prepend(INDENT)
            welcome_string << "in chronological order and without spoilers.\n".prepend(INDENT)
            welcome_string << "(data source: SPORTSMOLE.CO.UK)".prepend(INDENT)
        end
    end
end