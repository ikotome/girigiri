class Entry < ApplicationRecord
  belongs_to :user
  belongs_to :event

  enum :status, {
    todo: 0, drafting: 1, submitted: 2,
    skipped: 3, auto_closed: 4
  }
end
