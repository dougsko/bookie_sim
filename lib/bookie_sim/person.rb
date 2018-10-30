module BookieSim
    class Person
        attr_accessor :bet, :bankroll, :name
        def initialize(name, bankroll)
            @name = name
            @bet = []
            @bankroll = 1000
        end

        def make_bet(match, team, amount)
            puts "#{@name} bets $#{amount} on #{team.name}"
            @bet = Bet.new(self, match, team, amount)
            match.add_bet(@bet)
        end

        def gets_paid(amount)
            @bankroll += amount
            #puts "#{@name} now has #{@bankroll}"
        end

        def pays(person, amount)
            puts "#{self.name} pays #{person.name} $#{amount}"
            person.gets_paid(amount)
            @bankroll -= amount
        end

    end
end
