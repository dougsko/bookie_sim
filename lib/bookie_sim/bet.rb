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
                if client.is_bookie
                    odds = @match.online_home_odds
                else
                    odds = @match.home_odds
                end
            else
                if client.is_bookie
                    odds = @match.online_away_odds
                else
                    odds = @match.away_odds
                end
            end
            puts "Using odds: " + odds.to_s

            if odds > 0
                profit = @stake * (odds.abs / 100.0)
            else
                profit = @stake / (odds.abs / 100.0)
            end
            return profit.round(2)
        end

    end
end
