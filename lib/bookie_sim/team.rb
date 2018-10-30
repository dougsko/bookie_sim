module BookieSim
    class Team
        attr_reader :name
        def initialize(name)
            @name = name
            @wins = 0
            @losses = 0
        end

        def wins
            @wins += 1
        end

        def loses
            @losses += 1
        end
    end
end
