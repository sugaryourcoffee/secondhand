class QueryController < ApplicationController

  def index
    load_items
  end

  private

    def load_items
      keywords = params[:keywords]
      if keywords.nil? or keywords.strip.empty?
        @items = []
      else
        event = Event.find_by(active: true)
        @items = Item.where("description like ?", "%#{keywords}%")
                     .joins(:list).where("event_id = ?", event.id)
      end
    end
end
