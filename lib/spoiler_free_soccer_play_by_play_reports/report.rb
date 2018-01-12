module SpoilerFreeSoccerPlayByPlayReports
    class Report
        # I am aware that this is not a true inner class but is rather merely namespaced,
        # but it still feels cleaner than a hash or a non-namespaced class
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
        @@current_report= nil
        @@next_part_index = 0

        def initialize(report_hash)
            @team1 = report_hash[:team1] || "TEAM 1"
            @team2 = report_hash[:team2] || "TEAM 2"
            @details_url = report_hash[:details_url] || ""
            
            @byline = nil
            @blurbs = []
            @details_loaded = false
        end

        def self.all
            @@all
        end

        def self.get_report_abstracts
            SpoilerFreeSoccerPlayByPlayReports::Scraper.report_list.each do |report_hash|
                self.all << Report.new(report_hash)
            end
        end

        def self.load_current_report_details
            report_details = SpoilerFreeSoccerPlayByPlayReports::Scraper.report_details(@@current_report.details_url)

            @@current_report.byline = SpoilerFreeSoccerPlayByPlayReports::Report::Byline.new(report_details[:byline])

            report_details[:blurbs].each do |blurb_hash|
                @@current_report.blurbs << SpoilerFreeSoccerPlayByPlayReports::Blurb.new(blurb_hash)
            end

            @@current_report.details_loaded = true
        end

        def self.reset
            self.all.clear
        end

        def self.list(team_name)
            @@current_list.clear 

            if self.all.empty?
                self.get_report_abstracts
            end

            @@current_list = self.all.select do |report|
                'all' == team_name ||
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

        def self.report(report_index)
            @@current_report = @@current_list[report_index - 1]
            @@next_blurb_index = 0

            if !@@current_report.details_loaded
                self.load_current_report_details
            end

            @@current_report
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

    end
end