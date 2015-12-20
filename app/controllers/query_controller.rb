class QueryController < ApplicationController

  def index
    load_event
    load_items
  end

  private

    def load_event
      @event ||= Event.find_by(active: true)
    end

    def load_items
      keywords = params[:keywords]
      if !@event or keywords.nil? or keywords.strip.empty?
        @items = []
      else
        @items = Item.where("description like ?", "%#{keywords}%")
                     .joins(:list).where("event_id = ?", @event.id)
      end
    end
end
