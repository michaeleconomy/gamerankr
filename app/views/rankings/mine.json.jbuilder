json.partial! 'shared/pagination', page_info: @rankings
json.games @rankings.collect(&:game), partial: 'games/game', as: :game