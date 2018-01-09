module SpoilerFreeSoccerPlayByPlayReports
    class Scraper
        def self.report_list
            # source:
            # https://www.sportsmole.co.uk/football/live-commentary/

            doc = Nokogiri::HTML(open("https://www.sportsmole.co.uk/football/live-commentary/page-4/"))
            
            report_links = doc.search(".list_rep")
            hash_array = []

            report_links.each do |link|
                title = link.at(".list_rep_title div").text
                title.strip!

                # there are some items that are not live commentary; they have a different title format, e.g.
                # "Manchester United Newsdesk Live: Antoine Griezmann, David de Gea, Basel build-up, more"
                if !title.include?("Live Commentary: ")
                    next
                end
                title.gsub!("Live Commentary: ", "")
                title.gsub!(" - as it happened", "")
                team_names = title.split("-")
                team_names[0] = team_names[0].gsub(/\s\d+$/, "")
                team_names[1] = team_names[1].gsub(/^\d+\s/, "")

                # games that go to extra time or are resolved by penalties may have notes in parentheses
                # either after or before the name of the second team; 
                # these need to be stripped to extract the correct team name
                # e.g.
                # "Live Commentary: Manchester City 0-0 (4-1 on penalties) Wolverhampton Wanderers - as it happened"
                # "Live Commentary: Leicester 1-1 Manchester City (Man City win 4-3 on penalties) - as it happened"
                team_names[1] = team_names[1].gsub(/\s\(.*$/, "") # trailing parentheses
                team_names[1] = team_names[1].gsub(/^\(.*\)\s/, "") # leading parentheses

                hash_array << {:team1 => team_names[0], :team2 => team_names[1]}
            end

            # For each report summary thumbnail link, we must extract the names of the two teams
            # from a title formatted like so:
            # "Live Commentary: Celta Vigo 2-2 Real Madrid - as it happened"

            # These are the steps we need to work through to accomplish this:
            # extract title
            # strip "Live Commentary: " from the beginning
            # strip " - as it happened" from the end
            # split on "-"
            # strip "/ d*/" from end of left
            # strip "/d* /" from beginning of right
            # team1 => left, team2 => right
            # team1 in Premier League? team2 in Premier League?

            binding.pry

            hash_array

=begin
            [
                {:team1 => "Chelsea", :team2 => "Arsenal"}, 
                {:team1 => "Bournemouth", :team2 => "Swansea"}
            ]
=end
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