module SpoilerFreeSoccerPlayByPlayReports
    class Scraper
        def self.report_list()
            [
                {:team1 => "Chelsea", :team2 => "Arsenal"}, 
                {:team1 => "Bournemouth", :team2 => "Swansea"}
            ]
        end 

        # needs to be modified to take a url param
        def self.report_blurbs
            [
                {:label => "BLURB 1 LABEL", :text => "blurb one text"},
                {:label => "BLURB 2 LABEL", :text => "blurb two text"}
            ]
        end
    end
end