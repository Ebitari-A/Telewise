class Show < ApplicationRecord
  # searchkick word_start: ['name']

  validates :name, :summary, :number_of_seasons, presence: true
  has_many :reviews, dependent: :destroy
  has_many :episodes, dependent: :destroy
  has_many :season_summaries, dependent: :destroy
  has_many :followed_shows, dependent: :destroy
end
