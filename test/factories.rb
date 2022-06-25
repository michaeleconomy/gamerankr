FactoryBot.define do

  factory :user do
    real_name {"John"}
  end

  factory :game do
    title {"halo"}
  end

  factory :port do
    title {"halo"}
    game
    additional_data factory: :giant_bomb_port
    platform
  end

  factory :giant_bomb_port do
    giant_bomb_id {rand(2**32)}
    url {"https://www.giantbomb.com/mario-wario/3030-22862"}
    image_id {"461592-mariowariosfc_boxart.jpg"}
  end

  factory :platform do
    name {"playbox #{rand(2**32)}"}
  end

  factory :recommendation do
    user
    game {create(:port).game}
    algorithm {1}
    score {1.0}
  end

  factory :series do
    name {"halo series"}
  end

  factory :comment do
    user
    comment {"foo"}
    resource {create_ranking}
  end

  factory :follow do
    follower {create(:user)}
    following {create(:user)}
  end
end

def create_ranking(options = {})
  r = Ranking.new
  r.user = options[:user] || create(:user)
  r.port = options[:port] || create(:port)
  r.ranking = options[:ranking]
  r.review = options[:review]
  r.shelves << r.user.shelves.shuffle.first
  r.save!
  r
end