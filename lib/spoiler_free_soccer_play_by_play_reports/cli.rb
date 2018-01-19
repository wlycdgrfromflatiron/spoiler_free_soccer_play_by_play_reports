module SpoilerFreeSoccerPlayByPlayReports


    class CLI


        #########################################
        # CLI HELPER CLASS                      #
        # Keeps track of which screen we are on #
        # and whether we need to change it      #
        #########################################
        class State


            #########################
            # State CLASS CONSTANTS #
            #########################
            MAIN_MENU = 0
            MATCHES_LIST = 1
            TEAMS_LIST = 2
            REPORT = 3
            QUIT = 4


            ##################################
            # State CLASS INSTANCE VARIABLES #
            ##################################
            class << self
                attr_accessor :touched
                attr_reader :id
            end

            @id = MAIN_MENU
            @touched = false 


            ##############################
            # State PUBLIC CLASS METHODS #
            ##############################
            def self.set(id)
                @id = id
                @touched = true
            end
        end


        #####################################################
        # CLI HELPER CLASS                                  #
        # Asks for, captures, parses, and stores user input #
        #####################################################
        class Input


            #########################
            # Input CLASS CONSTANTS #
            #########################
            REGEX_MATCHES = /^m(atches)?\s*?/
            REGEX_NEXT = / /
            REGEX_QUIT = /^q(uit)?\s*$/
            REGEX_TEAMS = /^t(eams)?\s*?/

            DIVIDER = " | "
            MATCH_INDEX = "[match #]"
            MATCHES = "(M)atches"
            QUIT = "(Q)uit"
            TEAM_INDEX = "[team #]"
            TEAM_NAME = "[team name]"
            TEAMS = "(T)eams"


            #########################
            # Input CLASS VARIABLES #
            #########################
            @@value = nil


            ##############################
            # Input PUBLIC CLASS METHODS #
            ##############################
            def self.get(options)
                Printer.print(prompt(options))
                @@value = gets.strip
            end

            def self.get_unbuffered(prompt = nil)
                Printer.print(prompt) if prompt
                @@value = STDIN.getch
            end

            def self.integer
                @@value.to_i > 0
            end

            def self.matches
                @@value.match(REGEX_MATCHES)
            end

            def self.next
                @@value.match(REGEX_NEXT)
            end

            def self.quit
                @@value.match(REGEX_QUIT)
            end

            def self.teams
                @@value.match(REGEX_TEAMS)
            end

            def self.value
                self.integer ? @@value.to_i : @@value
            end


            ###############################
            # Input PRIVATE CLASS METHODS #
            ###############################
            def self.prompt(options)
                prompt = ""
                options.each {|option| prompt << option << DIVIDER}
                prompt << QUIT
            end

            private_class_method :prompt
        end


        ########################################
        # CLI HELPER CLASS                     #
        # Keeps error messages organized and   #
        # keeps track of current error, if any #
        ########################################
        class Error


            #########################
            # Error CLASS CONSTANTS #
            #########################
            INVALID_LIST_INDEX = "Invalid list index - please try again."
            NO_MATCH_REPORTS_FOR_TEAM = "No match reports are available for that team :(\n" \
                "...However, the parser is not the brightest.\n" \
                "You may want to double-check your spelling and/or try (T)eams just in case."
            NO_MATCH_REPORTS = "No match reports are currently available :("


            #########################
            # Error CLASS VARIABLES #
            #########################
            @@text = nil


            ##############################
            # Error PUBLIC CLASS METHODS #
            ##############################
            def self.text
                @@text ? @@text.prepend("ERROR: ") : @@text
            end

            def self.code=(code)
                @@text = code
            end
        end


        #######################
        # CLI CLASS CONSTANTS #
        #######################
        DESCRIPTION = "" \
            "~ SPOILER-FREE PLAY-BY-PLAY SOCCER MATCH REPORTS ~\n" \
            "A service for reading live commentaries for completed soccer matches\n" \
            "in chronological order and without spoilers.\n" \
            "(data source: SPORTSMOLE.CO.UK)"
        LOADING_MESSAGE = "Loading report list..."
        INSTRUCTIONS = "" \
            "MAIN MENU CONTROLS:\n" \
            "(M)atches:        List all matches for which reports are available.\n" \
            "(T)eams:          List all teams for which reports are available.\n" \
            "[team name]:      List all available reports for [team name].\n" \
            "(Q)uit:           Quit the program."
        TEAMS_LIST_HEADER = "TEAMS THAT HAVE REPORTS AVAILABLE"
        REPORT_CONTROLS = "" \
            "Controls:\n" \
            "[Spacebar]:      Show next report item.\n" \
            "m:               List all available match reports.\n" \
            "t:               List all teams for which reports are available.\n" \
            "q:               Quit the program."
        GOODBYE_MESSAGE = "Thanks for using this app. Goodbye!"


        #######################
        # CLI CLASS VARIABLES #
        #######################
        @@selected = {
            report_list: nil,
            report: nil,
            team: nil
        }


###########################
# CLI MAIN SEQUENCE START #
###########################
        # ENTRY POINT
        def self.start
            Printer.clear_screen
            Printer.puts([DESCRIPTION, LOADING_MESSAGE])
            Report.list('all')
            State.set(State::MAIN_MENU)
            self.main_loop
        end

        def self.main_loop
            while State::QUIT != State.id
                self.wash
                case State.id
                when State::MAIN_MENU
                    self.main_menu_loop
                when State::MATCHES_LIST
                    self.matches_list_loop(self.matches_list_header, self.matches_list)
                when State::TEAMS_LIST
                    self.teams_list_loop(self.teams_list)
                when State::REPORT
                    self.report_loop(self.report_title, self.report_byline)
                end
            end
            self.quit
        end

        def self.quit
            Printer.puts(GOODBYE_MESSAGE)
        end
        # EXIT POINT
#########################
# CLI MAIN SEQUENCE END #
#########################

        
        # #######################################################
        # CLI PUBLIC CLASS METHODS                              #
        # FIRST LEVEL: METHODS CALLED DIRECTLY BY MAIN SEQUENCE #
        #########################################################
        def self.wash
            State.touched = false
            Error.code = nil
        end

        def self.main_menu_loop
            while !State.touched
                Printer.clear_screen
                Printer.puts([DESCRIPTION, INSTRUCTIONS, Error.text])

                Input.get([Input::MATCHES, Input::TEAMS, Input::TEAM_NAME])

                if Input.quit
                    State.set(State::QUIT)
                elsif Input.matches
                    self.handle_matches_input
                elsif Input.teams
                    self.handle_teams_input
                else
                    self.handle_matches_input(Input.value)
                end
            end
        end

        def self.matches_list_header
            @@team_filter ?
                "AVAILABLE REPORT FOR #{@@team_filter}" :
                "ALL AVAILABLE REPORTS"
        end

        def self.matches_list
            Formatter.columnize(
                Report.matches(@@team_filter).collect.with_index(1) do |match, index|
                    "#{index}. #{match.team1} vs. #{match.team2}"
                end
            )
        end

        def self.matches_list_loop(matches_list_header, matches_list)
            while !State.touched
                Printer.clear_screen
                Printer.puts([matches_list_header, matches_list, Error.text])

                Input.get([Input::MATCH_INDEX, Input::MATCHES, Input::TEAMS, Input::TEAM_NAME])

                if Input.quit
                    State.set(State::QUIT)
                elsif Input.integer
                    self.handle_report_index_input(Input.value)
                elsif Input.matches
                    self.handle_matches_input
                elsif Input.teams
                    self.handle_teams_input
                else
                    self.handle_matches_input(Input.value)
                end
            end
        end

        def self.teams_list
            Formatter.columnize(
                Report.teams.collect.with_index(1) do |team_name, index|
                    "#{index}. #{team_name}"
                end
            )
        end

        def self.teams_list_loop(teams_list)
            while !State.touched
                Printer.clear_screen
                Printer.puts([TEAMS_LIST_HEADER, teams_list, Error.text])

                Input.get([Input::TEAM_INDEX, Input::MATCHES])

                if Input.quit
                    State.set(State::QUIT)
                elsif Input.integer
                    self.handle_teams_index_input(Input.value)
                elsif Input.matches
                    self.handle_matches_input
                end
            end
        end

        def self.report_title
            report = Report.selected

            "MATCH REPORT\n"
            "#{report.team1} VS. #{report.team2}"
        end

        def self.report_byline
            report = Report.selected

            "Author: #{report.byline.author}\n" \
            "Filed: #{report.byline.filed}\n" \
            "#{report.byline.updated}"
        end

        def self.report_loop(report_title, report_byline)
            Printer.clear_screen
            Printer.puts([report_title, report_byline, REPORT_CONTROLS])

            while !State.touched && !Report.done
                Input.get_unbuffered

                if Input.quit
                    State.set(State::QUIT)
                elsif Input.next
                    self.handle_next_blurb_input
                elsif Input.matches
                    self.handle_matches_input
                elsif Input.teams
                    self.handle_teams_input
                end
            end

            if Report.done
                Printer.puts(Report.conclusion)
                Input.get_unbuffered
            end
        end


        # #####################################################
        # CLI PUBLIC CLASS METHODS                            #
        # SECOND LEVEL: METHODS CALLED BY FIRST LEVEL METHODS #
        #######################################################
        def self.handle_matches_input(team_name)
            if !Report.matches(@@team_filter = team_name).empty?
                State.set(State::MATCHES_LIST)
            else
                Error.code = @@team_filter ? 
                    Error::NO_MATCH_REPORTS_FOR_TEAM : 
                    Error::NO_MATCH_REPORTS
            end
        end

        def self.handle_next_blurb_input
            blurb = Report.next_blurb
            Printer.puts(blurb.label)
            Printer.puts(blurb.paragraphs) 
        end

        def self.handle_report_index_input(input_number)
            if input_number > Report.current_list.size
                Error.code = Error::INVALID_LIST_INDEX
            else
                Report.select(input_number)
                State.id = State::REPORT
            end
        end

        def self.handle_team_index_input(input_number)
            if input_number > Report.teams.size
                Error.code = Error::INVALID_LIST_INDEX
            else
                @@team_filter = Reports.team[input_number - 1]
                State.id = State::MATCHES_LIST
            end
        end

        def self.handle_teams_input
            Report.teams.empty? ? 
                Error.code = Error::NO_MATCH_REPORTS : 
                State.id = State::TEAMS_LIST
        end
    end
end