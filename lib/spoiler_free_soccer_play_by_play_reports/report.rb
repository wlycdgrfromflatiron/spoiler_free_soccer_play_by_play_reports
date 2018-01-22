module SpoilerFreeSoccerPlayByPlayReports
    class Report
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

        attr_reader :team1, :team2, :details_url
        attr_accessor :details_loaded, :byline, :blurbs

        @@all = []
        @@teams = []
        @@current_list = []
        @@current_team_name = nil
        @@current_report= nil
        @@next_part_index = 0

        def initialize(report_hash)
            @team1 = report_hash[:team1] || "TEAM 1"
            @team2 = report_hash[:team2] || "TEAM 2"
            @details_url = report_hash[:details_url] || ""
            
            @byline = nil
            @blurbs = []
            @blurb_index = 0
            @details_loaded = false
        end

        def self.all
            @@all
        end

        def self.current_team_name
            @@current_team_name
        end

        def self.load_abstracts
            SpoilerFreeSoccerPlayByPlayReports::Scraper.report_list.each do |report_hash|
                self.all << Report.new(report_hash)
            end
        end

        def self.reset
            self.all.clear
        end

        def self.get_list(team_name = nil)
            @@current_list.clear 

            @@current_list = self.all.select do |report|
                !team_name ||
                0 == team_name.casecmp(report.team1) ||
                0 == team_name.casecmp(report.team2)
            end

            @@current_list
        end

        def self.matches(team_name=nil)
            @@current_list.clear

            if self.all.empty?
                self.get_report_abstracts
            end

            @@current_list = self.all.select do |report|
                !team_name ||
                0 == team_name.casecmp(report.team1) ||
                0 == team_name.casecmp(report.team2)
            end

            @@current_team_name = team_name

            @@current_list
        end

        def self.teams
            if @@teams.empty?
                if self.all.empty?
                    self.get_report_abstracts
                end

                self.all.each do |report|
                    @@teams << report.team1
                    @@teams << report.team2
                end

                @@teams.uniq!

                @@teams.sort!
            end

            @@teams
        end

        def self.full(report)
            if !report.details_loaded
                details = SpoilerFreeSoccerPlayByPlayReports::Scraper.report_details(report.details_url)
                report.byline = Byline.new(details[:byline])
                details[:blurbs].each do |blurb_hash|
                    report.blurbs << Blurb.new(blurb_hash)
                end
                report.details_loaded = true
            end

            report
        end

        def self.next_blurb
            next_blurb = @@current_report.blurbs[@@next_blurb_index]

            @@next_blurb_index +=1

            next_blurb
        end

        def self.done
            @@next_blurb_index >= @@current_report.blurbs.length
        end

        def self.conclusion
            "CONCLUSION OF THE #{@@current_report.team1} VS. #{@@current_report.team2} REPORT"
        end

        def self.select(index)
           @@current_report =  @@current_list[index - 1]
        end

        def self.selected
            @@current_report
        end
    end
end