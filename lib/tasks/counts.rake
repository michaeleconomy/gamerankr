task fix_counts: [:environment] do
  Tasks::CountFixer.fix_game_rankings_counts
  Tasks::CountFixer.fix_port_rankings_counts
end
