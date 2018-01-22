module SpoilerFreeSoccerPlayByPlayReports
    class Report
        class Details
            class Blurb
                attr_reader :label, :paragraphs

                def initialize(hash)
                    @label = hash[:label] || "[UNTITLED]"
                    @paragraphs = hash[:paragraphs] || ["[No text]"]
                end
            end # class Blurb

            class Byline
                attr_accessor :author, :filed, :updated

                def initialize(preamble_hash)
                    @author = preamble_hash[:author] || "AUTHOR UNKNONWN"
                    @filed = preamble_hash[:filed] || "FILING DATE UNKNOWN"
                    @updated = preamble_hash[:updated] || "LAST UPDATED DATE UNKNOWN"
                end
            end # class Byline

            attr_accessor :blurbs, :byline

            def initialize(details_hash)
                @blurbs = []
                details_hash[:blurbs].each do |blurb_hash|
                    @blurbs << Blurb.new(blurb_hash)
                end
                @byline = Byline.new(details_hash[:byline])
            end
        end # class Details

        attr_accessor :details, :details_url, :team1, :team2

        @@all = []

        
        ######################
        # Report CONSTRUCTOR #
        ######################
        def initialize(report_hash)
            @team1 = report_hash[:team1]
            @team2 = report_hash[:team2]
            @details_url = report_hash[:details_url]
            @details = nil
        end


        ###########################
        # Report INSTANCE METHODS #
        ###########################
        def blurb(index)
            blurb = nil
            if index < @details.blurbs.length
                blurb = @details.blurbs[index]
            end
        end

        
        ########################
        # Report CLASS METHODS #
        ########################
        def self.all
            @@all
        end

        def self.create(hash)
            self.all << Report.new(hash)
        end

        def self.list(team_name = nil)
            self.all.select do |report|
                !team_name ||
                0 == team_name.casecmp(report.team1) ||
                0 == team_name.casecmp(report.team2)
            end
        end

        def self.retrieve_details_from_website(report)
            report.details = Details.new(Scrape.report_details(report.details_url)) if !report.details
            report
        end

        def self.teams
            teams = []
            self.all.each do |report|
                teams << report.team1
                teams << report.team2
            end
            teams.uniq!
            teams.sort!
        end

    end # class Report

end # module SpoilerFreeSoccerPlayByPlayReports