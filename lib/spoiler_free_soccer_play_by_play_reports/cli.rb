module SpoilerFreeSoccerPlayByPlayReports


    class CLI


        ######################
        # CLI HELPER CLASSES #
        ######################
        class State


            #########################
            # State CLASS CONSTANTS #
            #########################
            MAIN_MENU = 0
            MATCHES_LIST = 1
            TEAMS_LIST = 2
            REPORT = 3
            QUIT = 4


            #########################
            # State CLASS VARIABLES #
            #########################
            @@id = MAIN_MENU
            @@touched = false
            

            ##############################
            # State PUBLIC CLASS METHODS #
            ##############################
            def self.id
                @@id
            end

            def self.id=(id)
                @@id= id
                @@touched = true
            end

            def self.touched
                @@touched
            end

            def self.touched=(value)
                @@touched = value
            end
        end


        class Input
            REGEX_MATCHES = /^m(atches)?\s*?/
            REGEX_NEXT_BLURB = / /
            REGEX_QUIT = /^q(uit)?\s*$/
            REGEX_TEAMS = /^t(eams)?\s*?/

            @@value = nil

            def self.get(prompt)
                print Formatter.indent(prompt)
                @@value = gets.strip
            end

            def self.quit
                @@value.match(REGEX_QUIT)
            end

            def self.matches
                @@value.match(REGEX_MATCHES)
            end

            def self.teams
                @@value.match(REGEX_TEAMS)
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
        @@error_message = ""
        @@report_index = nil
        @@selected_team = nil


###########################
# CLI MAIN SEQUENCE START #
###########################
        # ENTRY POINT
        def self.start
            Printer.clear_screen
            Printer.puts([DESCRIPTION, LOADING_MESSAGE])
            Report.list('all')
            State.id = State::MAIN_MENU
            main_loop()
        end

        def self.main_loop
            while State::QUIT != State.id
                wash()
                case State.id
                when State::MAIN_MENU
                    main_menu_loop()
                when State::MATCHES_LIST
                    matches_list_loop(matches_list_header(), matches_list())
                when State::TEAMS_LIST
                    teams_list_loop(teams_list())
                when State::REPORT
                    report_loop(report_title_and_byline())
                end
            end
            quit()
        end

        def self.quit
            Printer.puts([GOODBYE_MESSAGE])
        end
        # EXIT POINT
#########################
# CLI MAIN SEQUENCE END #
#########################

        
        # ###############################################
        # CLI PUBLIC CLASS METHODS                      #
        # FIRST LEVEL: CALLED DIRECTLY IN MAIN SEQUENCE #
        #################################################
        def self.wash
            State.touched = false
            @@error_message = ""
        end

        def self.main_menu_loop
            while !State.touched
                Printer.puts([DESCRIPTION, INSTRUCTIONS, @@error_message])

                Input.get("(M)atches | (T)eams | [team name] | (Q)uit: ")

                if Input.quit
                    State.id = State::QUIT
                elsif Input.matches
                    handle_matches_input(nil)
                elsif Input.teams
                    handle_teams_input()
                else
                    handle_matches_input(Input.value)
                end

                if input.match(REGEX_QUIT)
                    State.id = State::QUIT
                elsif input.match(REGEX_MATCHES)
                     handle_matches_input(nil)
                elsif input.match(REGEX_TEAMS)
                    handle_teams_input()
                else
                    handle_matches_input(input)
                end
            end
        end

        def self.matches_list_header
            @@selected_team ?
                "AVAILABLE REPORT FOR #{@@selected_team}" :
                "ALL AVAILABLE REPORTS"
        end

        def self.matches_list
            Formatter.columnize(
                Report.matches(@@selected_team).collect.with_index(1) do |match, index|
                    "#{index}. #{match.team1} vs. #{match.team2}"
                end
            )

        def self.matches_list_loop(header, matches_list)
            while !State.touched
                Printer.puts_output(header, matches_list, @@error_message)

                input = get_input("[match #] | (M)atches | (T)eams | [team name] | (Q)uit: ")

                if input.match(REGEX_QUIT)
                    State.id = State::QUIT
                elsif input.to_i > 0
                    handle_report_index_input(input.to_i)
                elsif input.match(REGEX_MATCHES)
                    handle_matches_input(nil)
                elsif input.match(REGEX_TEAMS)
                    handle_teams_input()
                else
                    handle_matches_input(input)
                end
            end
        end

        def self.teams_list
            Printer.columnize(
                Report.teams.collect.with_index(1) do |team_name, index|
                    "#{index}. #{team_name}"
                end
            )
        end

        def self.teams_list_loop(teams_list)
            while !State.touched
                Printer.puts_output(TEAMS_LIST_HEADER, teams_list, @@error_message)

                input = get_input "[team #] | (M)atches | (Q)uit: "

                if input.match(REGEX_QUIT)
                    State.id = State::QUIT
                elsif input.to_i > 0
                    handle_teams_index_input(input.to_i)
                elsif input.match(REGEX_MATCHES)
                    handle_matches_input(nil)
                end
            end
        end

        def self.report_title_and_byline
            report = Report.report(@@report_index)

            title_and_byline = 
                "#{INDENT}MATCH REPORT\n" \
                "#{INDENT}#{report.team1} VS. #{report.team2}\n" \
                "\n" \
                "#{INDENT}Author: #{report.byline.author}\n" \
                "#{INDENT}Filed: #{report.byline.filed}\n" \
                "#{INDENT}#{report.byline.updated}\n"
        end

        def self.report_loop(title_and_byline)
            Printer.print_output(title_and_byline, REPORT_CONTROLS)

            while !State.touched && !Report.done
                input = STDIN.getch

                if input.match(REGEX_QUIT)
                    State.id = State::QUIT
                elsif ' ' == input
                    handle_next_blurb_input()
                elsif input.match(REGEX_MATCHES)
                    handle_matches_input(nil)
                elsif input.match(REGEX_TEAMS)
                    handle_teams_input()
                end
            end

            if Report.done
                Printer.indented_puts(Report.conclusion)
                STDIN.getch
            end
        end


        # SECOND LEVEL
        # METHODS CALLED BY FIRST LEVEL METHODS
        def self.get_input(text)
            print "#{INDENT}#{text}"
            gets.strip
        end

        def self.handle_matches_input(team_name)
            @@selected_team = team_name

            if !Report.matches(@@selected_team).empty?
                State.id = State::MATCHES_LIST
            else
                @@error_message = @@selected_team ? 
                    "#{INDENT}No matches are available for #{@@selected_team} :(\n" \
                    "#{INDENT}...However, the parser is not the brightest.\n" \
                    "#{INDENT}You may want to double-check your spelling and/or try (T)eams just in case." 
                    : 
                    "#{INDENT}No matches are currently available :("
            end
        end

        def self.handle_next_blurb_input
            blurb = Report.next_blurb

            puts ""
            puts Formatter.indent("#{blurb.label}")
            blurb.paragraphs.each do |paragraph|
                puts Formatter.indent(paragraph)
            end 
        end

        def self.handle_report_index_input(input_number)
            if input_number > Report.current_list.size
                @@error_message = Formatter.indent("Invalid report number! Please try again.")
            else
                @@report_index == input_number
                State.id = State::REPORT
            end
        end

        def self.handle_team_index_input(input_number)
            if input_number > Report.teams.size
                @@error_message = Formatter.indent("Invalid index! Please try again.")
            else
                @@selected_team = Reports.team[input_number - 1]
                State.id = State::MATCHES_LIST
            end
        end

        def self.handle_teams_input
            Report.teams.empty? ?
                @@error_message = Formatter.indent("No reports are currently available for any teams :(") : 
                State.id = State::TEAMS_LIST
        end
    end
end