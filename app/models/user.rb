class User < ApplicationRecord
  has_many :entries
  has_many :events, through: :entries
end