#!/usr/bin/env ruby
#
#
#

require "bundler/setup"
require "bookie_sim"

include BookieSim

t1 = Team.new('Steelers')
t2 = Team.new('Browns')

bookie = Person.new('Bookie Bob', 1000)
online_bookie = Person.new('Bookie Bettie', 1000)
clients = []

10.times do 
    clients << Person.new(Faker::Name.first_name, 1000)
end

week_num = 1
loop do
    puts "---"
    puts "Week ##{week_num}"
    puts
    week_start_bankroll = bookie.bankroll

    # set up the match and bets
    match = Match.new(t1, t2)
    match.print_moneyline
    clients.each do |client|
        if rand(2) == 0
            client.make_bet(match, t1, rand(100))
        else
            client.make_bet(match, t2, rand(100))
        end
    end

    # show book
    match.show_book_balance(bookie.bankroll)

    # make lay off bets
    if match.net_liability > 0
        amount_to_lay_off = match.amount_to_lay_off
        team_to_lay_off = match.team_to_lay_off
        bookie.make_bet(match, team_to_lay_off, amount_to_lay_off)
    end

    match.show_winner

    # square up
    # first the bookie's bets
    if match.net_liability > 0
        payout = bookie.bet.calculate_payout
        if bookie.bet.winner?
            puts "#{bookie.name} wins"
            online_bookie.pays(bookie, payout)
        else
            puts "#{bookie.name} loses"
            bookie.pays(online_bookie, bookie.bet.stake)
        end
    end

    # now the clients
    clients.each do |client|
        payout = client.bet.calculate_payout
        if client.bet.winner?
            puts "#{client.name} wins"
            bookie.pays(client, payout)
        else
            puts "#{client.name} loses"
            client.pays(bookie, client.bet.stake)
        end
        puts
    end

    # figure out profits
    profit = bookie.bankroll - week_start_bankroll
    if profit > 0
        puts "#{bookie.name} made $#{profit.round(2)}".green
    else
        puts "#{bookie.name} lost $#{profit.round(2).abs}".red
    end
    if bookie.bankroll >= 1000
        puts "#{bookie.name} now has " + "$#{bookie.bankroll.round(2)}".green
    elsif bookie.bankroll <= 0
        puts "#{bookie.name} is broke!".bold.red
        exit
    else
        puts "#{bookie.name} now has " + "$#{bookie.bankroll.round(2)}".red
    end
    puts

    week_num += 1

    sleep 0.5
    #exit
end



