module SpoilerFreeSoccerPlayByPlayReports
    class CLI
        class State
            MAIN_MENU, QUIT, REPORT, REPORT_LIST, TEAM_LIST = 0, 1, 2, 3, 4

            class << self
                attr_accessor :id, :blurb_index
            end
        end 

        class Output
            DESCRIPTION = "" \
                "~ SPOILER-FREE PLAY-BY-PLAY SOCCER MATCH REPORTS ~\n" \
                "A service for reading live commentaries for completed soccer matches\n" \
                "in chronological order and without spoilers.\n" \
                "(data source: SPORTSMOLE.CO.UK)"
            LOADING_MESSAGE = "Scraping list of available reports..."
            MAIN_MENU_CONTROLS = "" \
                "MAIN MENU CONTROLS:\n" \
                "(M)atches:        List all matches for which reports are available.\n" \
                "(T)eams:          List all teams for which reports are available.\n" \
                "[team name]:      List all available reports for [team name].\n" \
                "(Q)uit:           Quit the program."
            TEAM_LIST_HEADER = "Reports are available for these teams:"
            REPORT_LIST_FOR_HEADER = "MATCH REPORTS FOR "
            REPORT_LIST_HEADER = "ALL AVAILABLE MATCH REPORTS"
            REPORT_CONTROLS = "" \
                "Controls:\n" \
                "Spacebar, n:     Show next report item.\n" \
                "m:               List all available match reports.\n" \
                "t:               List all teams for which reports are available.\n" \
                "q:               Quit the program."
            GOODBYE = "Thanks for using this app. Goodbye!"
            
            class << self
                attr_accessor :header, :body
            end
        end

        class Input
            REGEX_REPORT_LIST = /^m(atches)?$/
            REGEX_NEXT_BLURB = /^[ n]$/
            REGEX_QUIT = /^q(uit)?$/
            REGEX_TEAM_LIST = /^t(eams)?$/

            QUIT = "(Q)uit"
            REPORT_INDEX = "[match #]"
            REPORTS = "(M)atches"
            SEPARATOR = " | "
            TEAM_INDEX = "[team #]"
            TEAM_NAME = "[team name]"
            TEAMS = "(T)eams"
            TERMINATOR = ": "

            class << self
                attr_reader :value, :prompt
            end

            def self.as_index
                @value.to_i - 1
            end

            def self.as_string
                @value
            end

            def self.get_buffered
                Printer.print(@prompt)
                @value = gets.strip.downcase
            end

            def self.get_unbuffered
                Printer.print(@prompt)
                @value = STDIN.getch.downcase
            end

            def self.positive_integer?
                @value.to_i > 0
            end

            def self.prompt=(options)
                @prompt = ""
                if options
                    options.each {|option| @prompt << option << SEPARATOR}
                    @prompt << QUIT << TERMINATOR
                end
            end

            def self.match(regex)
                @value? @value.match(regex) : false
            end

            def self.valid_index?(list)
                self.positive_integer? && @value.to_i <= list.size
            end
        end

        class Error
            INVALID_INDEX = "Invalid index - please try again."
            NO_REPORTS_FOR_TEAM = "No match reports are available for that team :("
            NO_REPORTS = "No match reports are available :( :( :("
            NO_MORE_BLURBS = "~ THE END ~ || (M)atches | (T)eams | (Q)uit: "

            @@text = nil

            def self.text
                @@text
            end

            def self.code=(code)
                @@text = code
            end
        end

        class Selection
            class << self
                attr_accessor :report_list, :report, :team_name, :team_names
            end
        end

        def self.start
            Printer.clear_screen
            Printer.puts(Output::DESCRIPTION)
            Printer.puts(Output::LOADING_MESSAGE)
            Report.load_abstracts

            self.load_main_menu
            self.menus_loop

            puts ""
            Printer.puts(Output::GOODBYE)
        end

        def self.load_main_menu
            Output.header = Output::DESCRIPTION
            Output.body = Output::MAIN_MENU_CONTROLS
            Input.prompt = [Input::REPORTS, Input::TEAMS, Input::TEAM_NAME]
            State.id = State::MAIN_MENU
        end

        def self.menus_loop
            while State::QUIT != State.id
                Printer.clear_screen
                Printer.puts([Output.header, Output.body, Error.text])

                Input.get_buffered

                if Input.match(Input::REGEX_QUIT)
                    State.id = State::QUIT
                elsif Input.match(Input::REGEX_REPORT_LIST) 
                    self.show_report_list
                elsif Input.match(Input::REGEX_TEAM_LIST) 
                    self.show_team_list
                elsif Input.positive_integer?
                    if State.id == State::TEAM_LIST
                        Input.valid_index?(Selection.team_names) ?
                            self.show_report_list(Selection.team_names[Input.as_index]) :
                            Error.code = Error::INVALID_INDEX
                    elsif State.id == State::REPORT_LIST
                        if Input.valid_index?(Selection.report_list)
                            self.load_report_details(Selection.report_list[Input.as_index])
                            self.report_loop
                        else
                            Error.code = Error::INVALID_INDEX
                        end
                    end
                elsif Input.as_string
                    self.show_report_list(Input.as_string)
                end
            end 
        end

        def self.show_report_list(team_name = nil)
            Selection.report_list = Report.list(team_name)

            if Selection.report_list.empty?
                Error.code = team_name ? Error::NO_REPORTS_FOR_TEAM : Error::NO_REPORTS 
            else
                Output.header = team_name ? 
                    Output::REPORT_LIST_FOR_HEADER + team_name :
                    Output::REPORT_LIST_HEADER
                Output.body = Formatter.columnize(
                    Selection.report_list.collect.with_index(1) do |report, index|
                        "#{index}. #{report.team1} vs. #{report.team2}"
                    end
                )
                Error.code = nil
                Input.prompt = [Input::REPORT_INDEX, Input::REPORTS, Input::TEAMS, Input::TEAM_NAME]
                State.id = State::REPORT_LIST
            end
        end

        def self.show_team_list
            Selection.team_names = Report.teams

            if Selection.team_names.empty?
                Error.code = NO_REPORTS
            else
                Output.header = Output::TEAM_LIST_HEADER
                Output.body = Formatter.columnize(
                    Selection.team_names.collect.with_index(1) do |team_name, index|
                        "#{index}. #{team_name}"
                    end
                )
                Error.code = nil
                Input.prompt = [Input::REPORTS, Input::TEAM_INDEX]
                State.id = State::TEAM_LIST
            end
        end

        def self.load_report_details(report)
            Selection.report = report.load_details
            report = Selection.report

            Output.header = 
                "MATCH REPORT\n" \
                "#{report.team1} VS. #{report.team2}"
                
            byline = report.details.byline
            Output.body =
                "Author: #{byline.author}\n" \
                "Filed: #{byline.filed}\n" \
                "#{byline.updated}"

            Input.prompt = nil

            State.blurb_index = 0
            State.id = State::REPORT
        end

        def self.report_loop
            Printer.clear_screen
            Printer.puts([Output.header, Output.body, Output::REPORT_CONTROLS])

            while State::REPORT == State.id
                Input.get_unbuffered

                if Input.match(Input::REGEX_QUIT)
                    State.id = State::QUIT
                elsif Input.match(Input::REGEX_NEXT_BLURB)
                    self.print_next_blurb
                elsif Input.match(Input::REGEX_REPORT_LIST)
                    self.show_report_list
                elsif Input.match(Input::REGEX_TEAM_LIST)
                    self.show_team_list
                end
            end
        end

        def self.print_next_blurb
            if blurb = Selection.report.blurb(State.blurb_index)
                Printer.puts(blurb.label)
                Printer.puts(blurb.paragraphs)
                State.blurb_index += 1
            else
                Printer.puts(Error::NO_MORE_BLURBS)
            end
        end
    end
end