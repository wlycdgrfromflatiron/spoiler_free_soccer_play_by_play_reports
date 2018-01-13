module SpoilerFreeSoccerPlayByPlayReports
    class Blurb
        attr_reader :label, :paragraphs

        def initialize(hash)
            @label = hash[:label] || "[UNTITLED]"
            @paragraphs = hash[:paragraphs] || ["[No text]"]
        end
    end
end