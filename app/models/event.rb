class Event < ApplicationRecord
  has_many :deadlines
  has_many :entries

  enum :category, {
    intern: 0, hackathon: 1, event: 2, personal: 3
  }
end