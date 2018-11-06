module BookieSim
    class Match
        attr_accessor :winner, :home_team, :away_team, :home_odds, :away_odds, :online_home_odds, :online_away_odds, :bets, :liability_percentage, :liability_threshold, :amount_to_lay_off, :team_to_lay_off, :net_liability
        def initialize(home_team, away_team)
            @home_team = home_team
            @away_team = away_team

            # set odds to be a little less than what's found online
            @home_odds = generate_odds * -1
            @away_odds = generate_odds
            @online_home_odds = @home_odds + 5
            @online_away_odds = @away_odds + 5

            @bets = []
            @liability_percentage = 0
            @liability_threshold = 10 # risk 10% of bankroll

            if rand(2) == 0
                @winner = @home_team
                @home_team.wins
                @away_team.loses
            else
                @winner = @away_team
                @home_team.loses
                @away_team.wins
            end
        end

        def generate_odds
            odds = 1
            while(odds % 5 != 0)
                odds = rand(110..200)
            end
            #return 110 # keep things simple by setting the odds to -110 for both teams
            return odds
        end

        def print_moneyline
            puts "Matchup:"
            puts "#{@home_team.name} #{@home_odds}"
            puts "#{@away_team.name} #{@away_odds}"
            puts
        end

        def add_bet(bet)
            @bets << bet
        end

        def show_book_balance(bankroll)
            # tally bets
            home_total = 0
            away_total = 0
            total_bets = 0
            @bets.each do |bet|
                total_bets += bet.stake
                home_total += bet.stake if bet.team == @home_team
                away_total += bet.stake if bet.team == @away_team
            end

            # home team liability
            if @home_odds > 0
                @home_team_liability = (home_total * (@home_odds.abs / 100.0)).round(2)
                @bookie_home_liability = (home_total * (@online_home_odds.abs / 100.0)).round(2)
            else
                @home_team_liability = (home_total / (@home_odds.abs / 100.0)).round(2)
                @bookie_home_liability = (home_total / (@online_home_odds.abs / 100.0)).round(2)
            end

            # away team liability
            if @away_odds > 0
                @away_team_liability = (away_total * (@away_odds.abs / 100.0)).round(2)
                @bookie_away_liability = (away_total * (@online_away_odds.abs / 100.0)).round(2)
            else
                @away_team_liability = (away_total / (@away_odds.abs / 100.0)).round(2)
                @bookie_away_liability = (away_total / (@online_away_odds.abs / 100.0)).round(2)
            end

            # subtract wins from liability to get net liability 
            #@net_liability = [(@home_team_liability - away_total).round(2), (@away_team_liability - home_total).round(2)].max
            @net_liability = [(@home_team_liability - away_total).round(2), (@away_team_liability - home_total).round(2)].max

            # find the percentage of bankroll risked by net liability
            @liability_percentage = (@net_liability / bankroll * 100).round(2).abs

            # print it and show the percentage of bankroll risked by net
            # liability
            puts
            puts "$#{home_total.round(2)} on #{@home_team.name} : #{(home_total / total_bets.to_f * 100).round(2)}% of action : $#{@home_team_liability} liability"
            puts "$#{away_total.round(2)} on #{@away_team.name} : #{(away_total / total_bets.to_f * 100).round(2)}% of action : $#{@away_team_liability} liability"  
            if @net_liability < 0
                puts "$#{@net_liability}".green + " net liability : #{@liability_percentage}% of bankroll"
            else
                puts "$#{@net_liability}".red + " net liability : #{@liability_percentage}% of bankroll"
            end

            # figure out lay off bet
            #if @home_team_liability > @away_team_liability
            if @home_team_liability > away_total
                puts "Lay off on home team"
                @team_to_lay_off = @home_team
                need_to_win = (@home_team_liability - @away_team_liability).round(2)
                #need_to_win = (@home_team_liability - away_total).round(2)
                #need_to_win = (home_total - @away_team_liability).round(2)
                if @home_odds < 0
                    puts "stake = #{@net_liability} * (#{@online_home_odds} / 100)"
                    #@amount_to_lay_off = (@net_liability * (@online_home_odds / 100.0)).round(2).abs
                    @amount_to_lay_off = (need_to_win * (@online_home_odds / 100.0)).round(2).abs
                else
                    puts "stake = #{@net_liability} / (#{@online_home_odds} / 100)"
                    #@amount_to_lay_off = (@net_liability / (@online_home_odds / 100.0)).round(2).abs
                    @amount_to_lay_off = (need_to_win / (@online_home_odds / 100.0)).round(2).abs
                end
                #puts "amount to lay off = #{home_total - @bookie_home_liability - @home_team_liability}"
                @amount_to_lay_off = home_total - (@bookie_home_liability - @home_team_liability).abs
            else
                puts "Lay off on away team"
                @team_to_lay_off = @away_team
                need_to_win = (@away_team_liability - @home_team_liability).round(2)
                #need_to_win = (@away_team_liability - home_total).round(2)
                #need_to_win = (away_total - @home_team_liability).round(2)
                if @away_odds < 0
                    puts "stake = #{@net_liability} * (#{@online_away_odds} / 100)"
                    #@amount_to_lay_off = (@net_liability * (@online_away_odds / 100.0)).round(2).abs
                    @amount_to_lay_off = (need_to_win * (@online_away_odds / 100.0)).round(2).abs
                else
                    puts "stake = #{@net_liability} / (#{@online_away_odds} / 100)"
                    #@amount_to_lay_off = (@net_liability / (@online_away_odds / 100.0)).round(2).abs
                    @amount_to_lay_off = (need_to_win / (@online_away_odds / 100.0)).round(2).abs
                end
                @amount_to_lay_off = away_total - (@bookie_away_liability - @away_team_liability).abs
            end

            # show winner
            def show_winner
                puts
                puts "#{@winner.name} win"
                puts
            end
        end

    end
end
