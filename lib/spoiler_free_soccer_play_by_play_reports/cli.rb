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
            CLI_OPTION_MATCHES = '(M)atches'
            CLI_OPTION_TEAMS = '(T)eams'
            CLI_OPTION_TEAMNAME = '[team name]'

            REGEX_MATCHES = /^m(atches)?\s*?/
            REGEX_QUIT = /^q(uit)?\s*$/
            REGEX_TEAMS = /^t(eams)?\s*?/

            @@match_matches = false
            @@match_teams = false
            @@match_teamname = false 

            @@error_feedback = ""

            @@input_prompt = "Default InputHandler input prompt: "

            def self.build_input_prompt(options)
                
            end

            def self.set_input_options(options)
                @match_matches = options.include?(CLI_OPTION_MATCHES)
                @match_teams = options.include?(CLI_OPTION_TEAMS)
                @match_teamname = options.include?(CLI_OPTION_TEAMNAME)

                self.build_input_prompt(options)
            end

            def self.handle_input
                Printer.print(@error_feedback)

                Printer.print(@input_prompt)
                input = gets.strip

                if input.match(REGEX_QUIT)
                    State.set_state(State::QUIT)

                elsif @match_matches && input.match(REGEX_MATCHES)
                    self.handle_matches_input(nil)

                elsif @match_teams && input.match(REGEX_TEAMS)
                    if !Report.teams.empty?
                        StatePlayer.play(State::TEAMS_LIST)
                    else 
                        @@error_feedback = "No reports are currently available for any teams :("

                elsif @match_teamname
                    self.handle_matches_input(input)
                end
            end

            def self.handle_matches_input(team_name)
                if !Report.matches(team_name).empty?
                    StateManager.set_state(State::MATCHES_LIST)
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

            STATES = [
                MAIN_MENU,
                MATCHES_LIST,
                TEAMS_LIST,
                REPORT,
            ]

# main menu output string
=begin
            welcome_string = self.welcome
            controls_string = ""
            controls_string << "MAIN MENU CONTROLS:\n".prepend(INDENT)
            controls_string << "(M)atches:        List all matches for which reports are available.\n".prepend(INDENT)
            controls_string << "(T)eams:          List all teams for which reports are available.\n".prepend(INDENT)
            controls_string << "[team name]:      List all available reports for [team name].\n".prepend(INDENT)
            controls_string << "(Q)uit:           Quit the program.".prepend(INDENT)
=end

#matches list output string + input stuff 
=begin
            header_string = @@matches_list_team_name ? 
                "AVAILABLE REPORTS FOR #{@@matches_list_team_name.upcase}".prepend(INDENT) : 
                "ALL AVAILABLE REPORTS".prepend(INDENT)

            match_list_string = column_print(
                Report.matches(@@matches_list_team_name).collect.with_index(1) do |match, index|
                    "#{index}. #{match.team1} vs. #{match.team2}"
                end
            )

                            # User is trying to select a report to view
                if @@input.to_i > 0
                    if @@input.to_i > Report.matches(@@matches_list_team_name).size
                        @@error_string = "Invalid report number! Please try again."
                    else
                        @@report_index = @@input.to_i
                        self.state(STATE_REPORT)
                    end


                                    elsif @@matches_list_team_name && @@input.match(REGEX_MATCHES)
                    @@matches_list_team_name = nil
                    self.matches_list_loop

                    
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
=end

            INPUT_OPTIONS[MAIN_MENU] = 
                [InputHandler::CLI_OPTION_MATCHES, InputHandler::CLI_OPTION_TEAMS, InputHandler::CLI_OPTION_TEAMNAME]
            INPUT_OPTIONS[MATCHES_LIST] =
                [InputHandler::CLI_OPTION_REPORT_INDEX, InputHandler::CLI_OPTION_MATCHES, InputHanlder::CLI_OPTION_TEAMS]

            def initialize(id, input_options)
                @id = id
                @input_options = input_options
                @output_string = "Default output_string value for State #{@id}."
            end

            def set_output(output)
                @output_string = output
            end

            def update
                Printer.clear_print(@output_string)
                InputHandler.handle_input
            end
        end

        class StatePlayer
            @@current_state = nil
            @@states = []
            @@keep_playing = true

            def self.turn_on
                State::STATES.each do |state_id|
                    @@states << State.new(
                        state_id,
                        State::INPUT_OPTIONS[state_id]
                    )
                end
            end

            def self.play(state)
                self.load(state)

                while (@@keep_playing)
                    @@current_state.update
                end
            end

            def self.load(state)
                @@current_state = @@states.detect {|state| state.id == state}
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