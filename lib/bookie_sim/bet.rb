module BookieSim
    class Bet
        attr_reader :stake, :team, :client
        def initialize(client, match, team, stake)
            @client = client
            @match = match
            @team = team
            @stake = stake
        end

        def winner?
            return true if @match.winner == @team
            false
        end

        def calculate_payout
            if @team == @match.home_team
                odds = @match.home_odds
            else
                odds = @match.away_odds
            end

            if odds > 0
                profit = @stake * (odds.abs / 100.0)
                #puts "profit = " + profit.round(2).to_s
            else
                profit = @stake / (odds.abs / 100.0)
                #puts "profit = " + profit.round(2).to_s
            end
            #payout = @stake + profit.round(2)
            return profit.round(2)
            return payout
        end

    end
end
