class EventsController < ApplicationController
  before_action :set_event, only: [:edit, :update]

  def new
    @event = Event.new
    @deadline = Deadline.new
  end

  def edit
    @deadline = @event.deadlines.first_or_initialize
  end

  def analyze_url
    analyzer = UrlAnalyzer.new(params[:url])
    result = analyzer.analyze

    if result
      render json: result
    else
      render json: { error: analyzer.error_message || "解析できませんでした" }, status: :unprocessable_entity
    end
  end

  def create
    @event = Event.new(event_params)
    @deadline = Deadline.new(deadline_params)

    if @event.save
      @deadline.assign_attributes(event: @event)
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

  def update
    @deadline = @event.deadlines.first_or_initialize

    if @event.update(event_params)
      @deadline.assign_attributes(deadline_params)

      if @deadline.save
        redirect_to deadlines_path, notice: "更新しました"
      else
        render :edit, status: :unprocessable_entity
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_event
    @event = Event.find(params[:id])
  end

  def event_params
    params.require(:event).permit(:title, :category, :source_url, :organizer, :event_at, :notes, :is_personal)
  end

  def deadline_params
    params.require(:deadline).permit(:deadline_at, :label)
  end
end
