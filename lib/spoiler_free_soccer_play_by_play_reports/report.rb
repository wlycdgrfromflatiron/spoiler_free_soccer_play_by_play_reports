module SpoilerFreeSoccerPlayByPlayReports
    class Report
        attr_reader :team1, :team2

        @@all = []
        @@current_list = []

        def initialize(team1, team2)
            @team1 = team1
            @team2 = team2
        end

        def self.all
            @@all
        end

        def self.get_report_abstracts
            Scraper.report_list.each do |report_hash|
                self.all << Report.new(report_hash[:team1], report_hash[:team2])
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
    end
end