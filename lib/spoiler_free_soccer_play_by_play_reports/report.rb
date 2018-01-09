module SpoilerFreeSoccerPlayByPlayReports
    class Report
        attr_reader :team1, :team2, :parts

        @@all = []
        @@current_list = []
        @@current_report= nil
        @@next_part_index = 0

        def initialize(team1, team2)
            @team1 = team1
            @team2 = team2
            @parts = ['part1', 'part2', 'part3']
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

        def self.preamble(report_index)
            @@current_report = @@current_list[report_index - 1]
            @@next_part_index = 0

            "REPORT OF THE MATCH BETWEEN #{@@current_report.team1} and #{@@current_report.team2}"
        end

        def self.next_part
            next_part = @@current_report.parts[@@next_part_index]

            @@next_part_index +=1

            next_part
        end

        def self.done
            @@next_part_index >= @@current_report.parts.length
        end

        def self.conclusion
            "CONCLUSION OF THE #{@@current_report.team1} VS. #{@@current_report.team2} REPORT"
        end

    end
end