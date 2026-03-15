class EventsController < ApplicationController
  def new
    @event = Event.new
    @deadline = Deadline.new
  end

  def create
    @event = Event.new(event_params)
    if @event.save
      @deadline = Deadline.new(deadline_params.merge(event: @event))
      if @deadline.save
        # Entryも同時に作成（今はユーザーなしで仮作成）
        Entry.create!(event: @event, status: :todo)
        redirect_to deadlines_path, notice: "登録しました"
      else
        render :new, status: :unprocessable_entity
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def event_params
    params.require(:event).permit(:title, :category, :source_url, :organizer, :event_at, :notes, :is_personal)
  end

  def deadline_params
    params.require(:deadline).permit(:deadline_at, :label)
  end
end