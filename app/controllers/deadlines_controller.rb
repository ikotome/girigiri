class DeadlinesController < ApplicationController
  def index
    deadlines = Deadline.includes(:event)
      .where("deadline_at >= ?", Date.today)
      .sort_by(&:days_remaining)

    @grouped = deadlines.group_by(&:urgency)
  end
end