module SpoilerFreeSoccerPlayByPlayReports
    class Report
        class Details
            class Blurb
                attr_reader :label, :paragraphs
        
                def initialize(hash)
                    @label = hash[:label] || "[UNTITLED]"
                    @paragraphs = hash[:paragraphs] || ["[No text]"]
                end
            end

            class Byline
                attr_accessor :author, :filed, :updated

                def initialize(preamble_hash)
                    @author = preamble_hash[:author] || "AUTHOR UNKNONWN"
                    @filed = preamble_hash[:filed] || "FILING DATE UNKNOWN"
                    @updated = preamble_hash[:updated] || "LAST UPDATED DATE UNKNOWN"
                end
            end

            attr_accessor :blurbs, :byline

            def initialize(details_hash)
                @blurb_index = 0
                @blubs = []
                details_hash[:blurbs].each do |blurb_hash|
                    @blurbs << Blurb.new(blurb_hash)
                end
                @byline = Byline.new(details_hash[:byline])
            end
        end 

        attr_accessor :blurb_index, :details, :details_url, :team1, :team2

        @@all = []

        def initialize(report_hash)
            @team1 = report_hash[:team1]
            @team2 = report_hash[:team2]
            @details_url = report_hash[:details_url]

            @blurb_index = 0

            @details = nil
        end

        def self.all
            @@all
        end

        # We use our Scraper class here since we are loading the data from the website
        # Separating Report data model from Scraper gives us the flexibility to also do things like
        # Report.load_abstracts_from_database, ....from_API, etc, in the future
        def self.load_abstracts_from_website
            Scraper.report_list.each {|report_hash| self.all < Report.new(report_hash)}
        end

        def self.retrieve_basic_reports(team_name = nil)
            self.all.collect do |report|
                !team_name ||
                0 == team_name.casecmp(report.team1) ||
                0 == team_name.casecmp(report.team2)
            end
        end

        def self.retrieve_teams
            teams = []
            self.all.each do |report|
                teams << report.team1
                teams << report.team2
            end
            teams.uniq!
            teams.sort!
        end

        def self.retrieve_detailed_report_from_website(report)
            report.details = Details.new(Scraper.report_details(report.details_url)) if !report.details
            report
        end

        def next_blurb
            next_blurb = nil
            if @blurb_index < @details.blurbs.length
                next_blurb = @details.blurbs[@blurb_index]
                @blurb_index += 1
            end
        end
    end
end