FactoryBot.define do
  factory :user do
    real_name "John"
  end

  factory :game do
    title "halo"
  end

  factory :port do
    title "halo"
    game
    additional_data factory: :giant_bomb_port
    platform
  end

  factory :giant_bomb_port do
    giant_bomb_id 12431
    url "https://www.giantbomb.com/mario-wario/3030-22862"
    image_id "461592-mariowariosfc_boxart.jpg"
  end

  factory :platform do
    name "playbox 365"
  end
end