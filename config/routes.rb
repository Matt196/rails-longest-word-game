Rails.application.routes.draw do
  get 'game' ,to: "games#generate_grid"
  get 'score', to: "games#score_and_message"
end
