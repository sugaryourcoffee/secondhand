class EventUsersController < ApplicationController

  def index
    @event = Event.find_by(active: true)
    @lists = List.where(event_id: @event)
                 .where.not(user_id: nil)
                 .joins(:user)
                 .where("users.deactivated = ?", false)
  end

end
