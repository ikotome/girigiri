class Deadline < ApplicationRecord
  belongs_to :event

  def days_remaining
    (deadline_at.to_date - Date.today).to_i
  end

  def urgency
    case days_remaining
    when ..0  then :today
    when 1..3 then :soon
    when 4..7 then :week
    else           :later
    end
  end
end