module SpoilerFreeSoccerPlayByPlayReports
    class Report
        attr_reader :team1, :team2, :blurbs_url, :blurbs

        @@all = []
        @@current_list = []
        @@current_report= nil
        @@next_part_index = 0

        def initialize(report_hash)
            @team1 = report_hash[:team1] || "TEAM 1"
            @team2 = report_hash[:team2] || "TEAM 2"
            @blurbs_url = report_hash[:blurbs_url] || ""

            @blurbs = []
        end

        def self.all
            @@all
        end

        def self.get_report_abstracts
            SpoilerFreeSoccerPlayByPlayReports::Scraper.report_list.each do |report_hash|
                self.all << Report.new(report_hash)
            end
        end

        def self.get_current_report_blurbs
            SpoilerFreeSoccerPlayByPlayReports::Scraper.report_blurbs.each do |blurb_hash|
                @@current_report.blurbs << SpoilerFreeSoccerPlayByPlayReports::Blurb.new(blurb_hash)
            end
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

        def self.preamble(report_index)
            @@current_report = @@current_list[report_index - 1]
            @@next_blurb_index = 0

            if @@current_report.blurbs.empty?
                self.get_current_report_blurbs
            end

            "REPORT OF THE MATCH BETWEEN #{@@current_report.team1} and #{@@current_report.team2}"
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