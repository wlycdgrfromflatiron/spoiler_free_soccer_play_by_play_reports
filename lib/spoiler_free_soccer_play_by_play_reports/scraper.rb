module SpoilerFreeSoccerPlayByPlayReports
    class Scraper
        SOURCE_BASE_URL = "https://www.sportsmole.co.uk"

        def self.report_list
            # source:
            # https://www.sportsmole.co.uk/football/live-commentary/

            doc = Nokogiri::HTML(open(SOURCE_BASE_URL + "/football/live-commentary"))
            
            report_links = doc.search(".list_rep")
            hash_array = []

            # For each report summary thumbnail link, we must extract the names of the two teams
            # from a title formatted like so:
            # "Live Commentary: Celta Vigo 2-2 Real Madrid - as it happened"
            report_links.each do |link|
                title = link.at(".list_rep_title div").text
                title.strip!

                # there are some items that are not live commentary; they have a different title format, e.g.
                # "Manchester United Newsdesk Live: Antoine Griezmann, David de Gea, Basel build-up, more"
                if !title.include?("Live Commentary: ")
                    next
                end

                # skip live commentaries for soon-to-start matches, for which the title is of the form
                # Live Commentary: Real Madrid vs. Numancia - kickoff at 8.30pm
                if title.include?(" vs. ")
                    next
                end

                # also skip live commentary for in-progress-matches, for which the title is of the form
                # Live Commentary: Tottenham Hotspur 0-0 Everton - live 8'
                if title.include?(" - live ")
                    next
                end

                title.gsub!("Live Commentary: ", "")
                title.gsub!(" - as it happened", "")

                # having stripped the non-team-name bits from the front and end, we split on the score in the middle
                # splitting on the dash alone or the dash plus the numbers produces some false positives, 
                # so we also add the spaces
                team_names = title.split(/\s\d+-\d+\s/)

                # games that go to extra time or are resolved by penalties may have notes in parentheses
                # either after or before the name of the second team; 
                # these need to be stripped further to extract the correct team name
                # e.g.
                # "Live Commentary: Manchester City 0-0 (4-1 on penalties) Wolverhampton Wanderers - as it happened"
                # "Live Commentary: Leicester 1-1 Manchester City (Man City win 4-3 on penalties) - as it happened"
                team_names[1] = team_names[1].gsub(/\s\(.*$/, "") # trailing parentheses
                team_names[1] = team_names[1].gsub(/^\(.*\)\s/, "") # leading parentheses

                # When testploring this code with Pry, check multiple pages at the live commentary URL
                # to find examples of the above irregularities, and keep an eye out for any others that may
                # need to be accounted for, as well as any changes to the standard format
                # this code works as of January 2018

                hash_array << {
                    :team1 => team_names[0], 
                    :team2 => team_names[1],
                    :details_url => link.attribute("href").value
                }
            end

            if WLY_DEBUG
                binding.pry
            end
 
            hash_array
        end 

        def self.report_details(details_url)
            doc = Nokogiri::HTML(open(SOURCE_BASE_URL + details_url))

            report_details = {}

            report_details[:byline] = {
                :author => doc.at(".article_byline a").text || nil,
                :filed => doc.at(".article_byline span").text || nil,
                :updated => doc.at(".article_byline div.last_updated").text || nil
            }

            scraped_blurbs = doc.search(".livecomm")

            report_details[:blurbs] = []
            scraped_blurbs.each do |scraped_blurb|
                blurb_text_span = scraped_blurb.at("span.post")

                blurb_text = blurb_text_span.text
                
                blurb_text.gsub!(/([?.!])([^?.!\s])/, "\\1\n\n\\2")

                report_details[:blurbs] << {
                    :label => scraped_blurb.at("a.period").text,
                    :text => blurb_text
                }
            end

            if WLY_DEBUG
                binding.pry
            end

            report_details
        end
    end
end