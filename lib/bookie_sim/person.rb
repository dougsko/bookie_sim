module BookieSim
    class Person
        attr_accessor :bet, :bankroll, :name, :is_bookie
        def initialize(name, bankroll, is_bookie)
            @name = name
            @bet = []
            @bankroll = bankroll
            @is_bookie = is_bookie
        end

        def make_bet(match, team, amount)
            puts "#{@name} has $#{@bankroll.round(2)} and bets $#{amount.round(2)} on #{team.name}"
            @bet = Bet.new(self, match, team, amount)
            match.add_bet(@bet)
        end

        def gets_paid(amount)
            @bankroll += amount
            #puts "#{@name} now has #{@bankroll}"
        end

        def pays(person, amount)
            puts "#{self.name} pays #{person.name} $#{amount.round(2)}"
            person.gets_paid(amount)
            @bankroll -= amount
        end

        def is_broke?
            return true if @bankroll <= 0
            false
        end
    end
end
