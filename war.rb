require 'pry'
require 'byebug'
class Card
  attr_accessor :power

  def initialize(suit, name, power)
    @suit = suit
    @name = name
    @power = power
  end

  def <=>(other_card)
    @power <=> other_card.power
  end

  def to_s
    "#{@name} of #{@suit}"
  end
end

class NoCard < Card
  def initialize
    @power = 0
  end

  def to_s
    "No card"
  end
end

class Deck
  def initialize(cards=[])
    @cards = cards
  end

  def make_full_deck!
    @cards = []
    [:spades, :clubs, :hearts, :diamonds].each do |suit|
      (2..10).to_a.concat([:Jack, :Queen, :King, :Ace]).each_with_index do |name, index|
        @cards << Card.new(suit, name, index + 1)
      end
    end
  end

  def deal!(decks)
    while(true) do
      decks.each do |deck|
        return if @cards.empty?
        deck.add_to_top! pull_from_top!
      end
    end
  end

  def shuffle!
    @cards.shuffle!
  end

  def add_to_top!(card)
    @cards.unshift(card)
  end

  def add_to_bottom!(cards)
    @cards.concat cards
  end

  def pull_from_top!
    @cards.shift || NoCard.new
  end

  def card_count
    @cards.count
  end

  def power
    @cards.reduce(0) {|acc, card| acc + card.power}
  end
end

class War
  def initialize(player_count)
    full_deck = Deck.new
    full_deck.make_full_deck!
    full_deck.shuffle!

    @players = player_count.times.map { Deck.new }

    full_deck.deal! @players

    play_game!
  end

  def play_game!
    round = 0
    while @players.count > 1
      round += 1
      puts "- Round #{round}"
      @players.each_with_index do |p, i|
        puts "Player #{i + 1} - #{p.card_count} cards #{p.power} points"
      end

      winner, loot = find_winner! @players
      winner.add_to_bottom!(loot)

      @players.select! { |p| p.card_count > 0 }
    end
  end

  def find_winner!(players, carryover=[])
    if carryover.any? # at war
      puts 'war!'
      players.each do |player|
        2.times do
          carryover << player.pull_from_top!
        end
      end
    end
    # {card => player}
    in_play = players.reduce({}) do |acc, player|
      acc[player.pull_from_top!] = player
      acc
    end

    winning_cards = in_play.keys.group_by(&:power).max.last
    loot = in_play.keys.concat(carryover)
    loot.select! {|c| !c.is_a? NoCard }
    if winning_cards.count == 1
      [in_play[winning_cards[0]], loot]
    else
      players = in_play.values_at(*winning_cards)
      find_winner!(players, loot)
    end
  end

end

War.new 2
