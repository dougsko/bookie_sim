#!/usr/bin/env ruby
#
#
#

require "bundler/setup"
require "bookie_sim"
require 'csv'
require 'tempfile'

include BookieSim

t1 = Team.new('Steelers')
t2 = Team.new('Browns')

bookie = Person.new('Bookie Bob', 5000, true)
online_bookie = Person.new('Bookie Bettie', 1000000000, true)
clients = []

10.times do 
    clients << Person.new(Faker::Name.first_name, 500, false)
end

csv = CSV.open("/tmp/bookie.csv", "wb", :headers => true)
headers = []
headers << bookie.name
clients.each {|client| headers << client.name}
csv << headers

week_num = 1
loop do
    puts "---"
    puts "Week ##{week_num}"
    puts
    week_start_bankroll = bookie.bankroll

    #puts "#{online_bookie.name} has #{online_bookie.bankroll.round(2)}"

    # is everyone else broke?
    if clients.all? {|client| client.is_broke? }
        puts "You won ALL THE MONEY!".green
        csv.close
        system("/Users/dprostko/bin/bookie_sim/plot.gnuplot &")
        sleep 0.1
        File.delete("/tmp/bookie.csv")
        exit
    end

    # save bankrolls in csv file
    data = [bookie.bankroll.round(2)]
    clients.each{|client| data << client.bankroll.round(2)}
    csv << data

    # set up the match and bets
    match = Match.new(t1, t2)
    match.print_moneyline
    clients.each do |client|
        next if client.is_broke?

        if client.bankroll < 10
            bet = client.bankroll
        else
            bet = rand([client.bankroll, bookie.bankroll].min).round(2)
            #bet = 100 if bet > 100
        end
        if rand(2) == 0
            client.make_bet(match, t1, bet)
        else
            client.make_bet(match, t2, bet)
        end
    end

    # show book
    match.show_book_balance(bookie.bankroll)

    # make lay off bets
    bookie_made_bet = false
    if match.net_liability > 0 #and match.liability_percentage > 2
        bookie_made_bet = true
        if bookie.bankroll > match.amount_to_lay_off
            bookie.make_bet(match, match.team_to_lay_off, match.amount_to_lay_off)
        else
            puts "DANGER! Betting entire bankroll".red
            #sleep 1
            bookie.make_bet(match, match.team_to_lay_off, bookie.bankroll)
        end
    end

    match.show_winner

    # square up
    # first the bookie's bets
    if match.net_liability > 0 and bookie_made_bet == true
        payout = bookie.bet.calculate_payout
        if bookie.bet.winner?
            puts "#{bookie.name} wins"
            online_bookie.pays(bookie, payout)
        else
            puts "#{bookie.name} loses"
            bookie.pays(online_bookie, bookie.bet.stake)
        end
        puts
    end

    # now the clients
    clients.each do |client|
        next if client.is_broke?
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

    #sleep 0.5
    #exit
end



