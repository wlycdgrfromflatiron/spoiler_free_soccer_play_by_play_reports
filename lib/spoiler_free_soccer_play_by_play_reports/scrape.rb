module SpoilerFreeSoccerPlayByPlayReports
    class Scrape
        SOURCE_BASE_URL = "https://www.sportsmole.co.uk"


        ########################
        # PUBLIC CLASS METHODS #
        ########################
        def self.report_abstracts
            doc = Nokogiri::HTML(open(SOURCE_BASE_URL + "/football/live-commentary"))
            report_links = doc.search(".list_rep")
            
            # For each report summary thumbnail link, we must extract the names of the two teams
            # from a title formatted like so:
            # "Live Commentary: Celta Vigo 2-2 Real Madrid - as it happened"
            report_links.each do |link|
                title = link.at(".list_rep_title div").text
                title.strip!

                next if !completed_match_report?(title)

                team_names = scrape_team_names(title)

                Report.create({
                    :team1 => team_names[0],
                    :team2 => team_names[1],
                    :details_url => link.attribute("href").value
                })
            end
        end 

        def self.report_details(details_url)
            doc = Nokogiri::HTML(open(SOURCE_BASE_URL + details_url))
            report_details = {}

            report_details[:byline] = scrape_byline(doc)

            report_details[:blurbs] = []
            scraped_blurbs = doc.search(".livecomm")
            scraped_blurbs.each do |scraped_blurb|
                report_details[:blurbs] << {
                    :label =>scraped_blurb.at("a.period").text,
                    :paragraphs => scrape_paragraphs(scraped_blurb)
                }
            end

            report_details
        end


        #########################
        # PRIVATE CLASS METHODS #
        #########################
        def self.scrape_team_names(title)
            title = strip_standard_bits(title)

            # having stripped the non-team-name bits from the front and end, we split on the score in the middle
            # splitting on the dash alone or the dash plus the numbers produces some false positives, 
            # so we also add the spaces
            team_names = title.split(/\s\d+-\d+\s/)

            # games that go to extra time or are resolved by penalties may have notes in parentheses
            # either after or before the name of the second team; 
            # these need to be stripped further to extract the correct team name. e.g.:
            # "Live Commentary: Manchester City 0-0 (4-1 on penalties) Wolverhampton Wanderers - as it happened"
            # "Live Commentary: Leicester 1-1 Manchester City (Man City win 4-3 on penalties) - as it happened"
            team_names[1] = team_names[1].gsub(/\s\(.*$/, "") # trailing parentheses
            team_names[1] = team_names[1].gsub(/^\(.*\)\s/, "") # leading parentheses

            team_names
        end

        def self.completed_match_report?(title)
             # there are some items that are not live commentary; they have a different title format, e.g.
            # "Manchester United Newsdesk Live: Antoine Griezmann, David de Gea, Basel build-up, more"
            title.include?("Live Commentary: ") &&

            # skip live commentaries for soon-to-start matches, for which the title is of the form
            # Live Commentary: Real Madrid vs. Numancia - kickoff at 8.30pm
            !title.include?(" vs. ") &&
            
            # also skip live commentary for in-progress-matches, for which the title is of the form
            # Live Commentary: Tottenham Hotspur 0-0 Everton - live 8'
            title.include?(" - as it happened")
        end

        def self.strip_standard_bits(title)
            title.gsub!("Live Commentary: ", "")
            title.gsub!(" - as it happened", "")
        end

        def self.scrape_byline(doc)
            {
                :author => doc.at(".article_byline a").text || nil,
                :filed => doc.at(".article_byline span").text || nil,
                :updated => doc.at(".article_byline div.last_updated").text || nil
            }
        end

        def self.scrape_paragraphs(blurb)
            paragraphs = []

            # handle blurbs that are TWEETS
            if blurb_is_tweet?(blurb)
                paragraphs << "~ A Tweet was here ~"

            else 
                text_span = blurb.at("span.post")
                span_kids_index = 0 
                index = 0
                span_kid = nil

                paragraphs[index] = ""
                while (span_kid = text_span.children[span_kids_index])
                    span_kids_index += 1

                    if ("p" == span_kid.name)
                        index += 1; paragraphs[index] = ""
                        paragraphs[index] << span_kid.text
                        index += 1; paragraphs[index] = ""
                    else
                        paragraphs[index] << span_kid.text
                    end
                end
            end

            paragraphs
        end

        def self.blurb_is_tweet?(blurb)
            "twitter-tweet" == blurb.at("span.post").children[0].attr("class")
        end

        private_class_method :scrape_team_names, :completed_match_report?, :strip_standard_bits,
            :scrape_byline, :scrape_paragraphs, :blurb_is_tweet?
    end
end