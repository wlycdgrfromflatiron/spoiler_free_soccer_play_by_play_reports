module SpoilerFreeSoccerPlayByPlayReports
    class Blurb
        attr_reader :label, :text

        def initialize(hash)
            @label = hash[:label] || "[UNTITLED]"
            @text = hash[:text] || "[No text]"
        end
    end
end