json.partial! 'shared/pagination', page_info: @results
json.results @results, partial: 'games/game', as: :game