class EntriesController < ApplicationController
  def update_status
    entry = Entry.find(params[:id])
    entry.update!(status: params[:status])
    redirect_to deadlines_path
  end
end