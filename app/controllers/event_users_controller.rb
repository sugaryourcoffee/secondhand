class EventUsersController < ApplicationController

  def index
    load_event
    load_lists
  end

  def print
    load_event
    respond_to do |format|
      format.pdf do
        send_data @event.sellers_to_pdf, content_type: Mime::PDF
      end
    end
  end

  private

  def load_event
    @event = Event.find_by(active: true)
  end

  def load_lists
    @lists = @event.seller_lists
  end

end
