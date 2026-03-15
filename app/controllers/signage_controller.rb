class SignageController < ApplicationController
  layout "signage"

  def show
    @deadlines = Deadline.includes(:event)
      .where("deadline_at >= ?", Date.today)
      .sort_by(&:days_remaining)
      .first(5)
    @today = Date.today
  end
end