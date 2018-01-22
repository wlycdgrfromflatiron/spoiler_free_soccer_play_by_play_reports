class CLI
    class State
        MAIN_MENU, TEAMS_LIST, REPORT, MATCHES_LIST = 0, 1, 2, 3

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
        TEAM_REPORTS_HEADER = "MATCH REPORTS FOR "
        ALL_REPORTS_HEADER = "ALL AVAILABLE MATCH REPORTS"
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
        REGEX_MATCHES = /^m(atches)?$/
        REGEX_NEXT_BLURB = /^[ n]$/
        REGEX_QUIT = /^q(uit)?$/
        REGEX_TEAMS = /^t(eams)?$/

        SEPARATOR = " | "
        MATCHES = "(M)atches"
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
            options.each {|option| @prompt << option << SEPARATOR}
            @prompt << QUIT << TERMINATOR
        end

        def self.match(regex)
            @value.match(regex)
        end

        def self.valid_index?(list)
            self.positive_integer? && @value.to_i <= list.size
        end
    end

    class Error
        INVALID_INDEX = "Invalid index - please try again."
        NO_REPORTS_FOR_TEAM = "No match reports are available for that team :("
        NO_REPORTS = "No match reports are available"
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
            attr_accessor :report_abstracts, :detailed_report, :team_name, :team_names
        end
    end

    def self.start
        Printer.clear_screen
        Printer.puts(Output::DESCRIPTION)
        Printer.puts(Output::LOADING_MESSAGE)
        Scrape.report_abstracts
        Report.load_abstracts_from_website

        self.load_main_menu
        self.menus_loop

        Printer.puts(Output::GOODBYE)
    end

    def self.load_main_menu
        Output.body = Output::DESCRIPTION
        Output.header = Output::MAIN_MENU_CONTROLS
        Input.prompt = [Input::MATCHES, Input::TEAMS, Input::TEAM_NAME]
        State.id = State::MAIN_MENU
    end

    def self.menus_loop
        while !Input.match(Input::QUIT)
            Printer.clear_screen
            Printer.puts([Output.header, Output.body, Error.text])

            Input.get_buffered

            if Input.match(Input::REGEX_MATCHES)
                self.load_report_abstracts

            elsif Input.match(Input::REGEX_TEAMS)
                self.load_team_names
            
            elsif Input.positive_integer? && State::TEAMS_LIST == State.id
                Input.valid_index?(Selection.team_names) ?
                    self.load_report_abstracts(Selection.team_names[Input.as_index]) :
                    Error.code = Error::INVALID_INDEX
            
            elsif Input.positive_integer? && State::MATCHES_LIST == state.id
                if Input.valid_index?(Selection.report_abstracts)
                    self.load_report(Selection.report_abstracts[Input.as_index])
                    self.report_loop
                else
                    Error.code = Error::INVALID_INDEX
                end

            else
                self.load_matches_list(Input.as_string)
            end
        end 
    end

    def self.load_report_abstracts(team_name = nil)
        Selection.report_abstracts = Report.matches(team_name)

        if Selection.matches_list.empty?
            Error.code = team_name ? Error::NO_REPORTS_FOR TEAM : Error::NO_REPORTS 
        else
            Output.header = team_name ? 
                Output::TEAM_REPORTS_HEADER + team_name :
                Output::ALL_REPORTS_HEADER
            Output.body = Formatter.columnize(
                Selection.matches_list.collect.with_index(1) do |match, index|
                    "#{index}. #{match.team1} vs. #{match.team2}"
                end
            )
            Error.code = nil
            State.id = State::MATCHES_LIST
        end
    end

    def self.load_teams_list
        @@teams_list = Report.teams

        @@header = "Reports are available for these teams:"
        @@body = Formatter.columnize(
            @@teams_list.collect.with_index(1) do |team, index|
                "#{index}. #{team}"
            end
        )
        @@error = nil

        State.set(State::TEAMS_LIST)
    end

    def self.load_report(report_abstract)
        Selection.detailed_report = Report.full(report_abstract)
        report = Selection.detailed_report

        Output.report_title = 
            "MATCH REPORT\n" \
            "#{report.team1} VS. #{report.team2}"
            
        byline = report.byline
        Output.report_byline = 
            "Author: #{byline.author}\n" \
            "Filed: #{byline.filed}\n" \
            "#{byline.updated}"

        State.blurb_index = 0
    end

    def self.report_loop
        Printer.clear_screen
        Printer.puts([Output::header, Output::body, Output::REPORT_CONTROLS])

        while State::REPORT == State.id
            Input.get_unbuffered

            if Input.match(REGEX_QUIT)
                State.id = State::QUIT

            elsif Input.match(REGEX_NEXT_BLURB)
                self.print_next_blurb

            elsif Input.matches
                self.load_matches_list

            elsif Input.teams
                self.load_teams_list

            end
        end
    end

    def self.print_next_blurb
        if blurb = Selection.detailed_report.blurb(State.blurb_index)
            Printer.puts(blurb.label)
            Printer.puts(blurb.paragraphs)
            State.blurb_index += 1
        else
            Printer.puts(Error::NO_MORE_BLURBS)
        end
    end