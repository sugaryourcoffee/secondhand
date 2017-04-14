class EventsController < ApplicationController
  include EventsHelper
  include ActionController::Live

  # GET /events
  # GET /events.json
  def index
    @events = Event.order(:event_date).paginate(page: params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @events }
    end
  end

  # GET /events/1
  # GET /events/1.json
  def show
    @event = Event.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @event }
    end
  end

  def print_pickup_tickets
    @event = Event.find(params[:id])
    respond_to do |format|
      format.html
      format.pdf do
        send_data @event.pickup_tickets_pdf, content_type: Mime::PDF
      end
    end
  end

  def print_lists
    @event = Event.find(params[:id])
    if carts_empty_for_printing?
      respond_to do |format|
        format.html
        format.pdf do
          send_data @event.lists_to_pdf, content_type: Mime::PDF
        end
      end
    else
      redirect_to events_path
    end
  end

  def create_lists_as_pdf
    @event = Event.find(params[:id])
    response.headers['Content-Type'] = 'text/event-stream' 
    if carts_empty_for_printing?
      @event.create_lists_as_pdf(response)
    else
      response.stream.write("data: #{{done: true, 
                                      file: 'no-file'}.to_json}\n\n")
    end
  ensure
    response.stream.close
  end

  def download_lists_as_pdf
    if carts_empty_for_printing?
      if File.exists?(params[:file])
        send_file(params[:file], content_type: Mime::PDF)
      else
        flash[:warning] = "No file available for download, please try again"
        redirect_to events_path
      end
    else
      redirect_to events_path
    end
  end

  # GET /events/new
  # GET /events/new.json
  def new
    @event = Event.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @event }
    end
  end

  # GET /events/1/edit
  def edit
    @event = Event.find(params[:id])
  end

  # POST /events
  # POST /events.json
  def create
    @event = Event.new(event_params) #params[:event])

    respond_to do |format|
      if @event.save
        create_lists(@event)
        format.html { redirect_to @event, 
                      notice: I18n.t('.created', 
                                     model: t('activerecord.models.event')) }
        format.json { render json: @event, status: :created, location: @event }
      else
        format.html { render action: "new" }
        format.json { render json: @event.errors, 
                      status: :unprocessable_entity }
      end
    end
  end

  # PUT /events/1
  # PUT /events/1.json
  def update
    @event = Event.find(params[:id])

    params[:max_lists] = create_lists(@event, params[:event][:max_lists].to_i)

    respond_to do |format|
      if @event.update_attributes(event_params) #params[:event])
        format.html { redirect_to @event, 
                      notice: I18n.t('.updated',
                                     model: t('activerecord.models.event')) }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @event.errors, 
                      status: :unprocessable_entity }
      end
    end
  end

  def create_lists(event, max_lists=event.max_lists)
    lists = List.where(event_id: event.id) || [] 
    list_count_to_create = max_lists - lists.count

    return max_lists if list_count_to_create == 0
    
    if list_count_to_create > 0
      codes = lists.collect {|list| list.registration_code}
      list_numbers = get_unassigned_list_numbers(lists, max_lists)
      codes = create_registration_codes(list_numbers, codes, 7) 

      list_numbers.each do |list_number|
        list = {list_number: list_number, 
                registration_code: codes[list_number - 1],
                event_id: event.id} 
        List.create(list)
        list_count_to_create -= 1
      end
    elsif list_count_to_create < 0
      list_count_to_delete = list_count_to_create * -1
      1.upto(list_count_to_delete) do |i|
        list = lists.pop
        redo unless list.user_id.nil?
        list.destroy
        list_count_to_create += 1
      end
    end

    max_lists + list_count_to_create 
  end
=begin
  def create_registration_codes(numbers, codes, size)
    numbers.each do |number|
      code = number.to_s.crypt("#{Random.new_seed}")[1..size]
      redo if codes.find_index(code)
      codes.insert(number-1, code)
    end
    codes
  end
=end

  def get_unassigned_list_numbers(lists, list_count)
    list_numbers = lists.collect {|list| list.list_number}
    unassigned = Array.new(list_count)
    unassigned.fill {|i| i+1}
    unassigned - list_numbers
  end

  # Inverts the the active flag of the event. If another event has a set active
  # flag it is set to false. Only one event can have set the active event set
  # POST /events/1/activate
  def activate
    @event = Event.find(params[:id])
    if carts_empty?
      @event.active = @event.active ? false : true
      updated_events = []
      updated_events << @event
      Event.all.each do |event|
        next if event.id == params[:id]
        if event.active
          event.active = false
          updated_events << event
        end 
      end if @event.active
      updated_events.each { |e| e.save }
    end
    respond_to do |format|
      format.html { redirect_to events_url }
      format.json { head :no_content }
    end
  end

  # DELETE /events/1
  # DELETE /events/1.json
  def destroy
    @event = Event.find(params[:id])

    @event.destroy

    if @event.errors.any?
      flash[:error] = @event.errors.full_messages.first
    else
      flash[:notice] = I18n.t('.destroyed', 
                              model: t('activerecord.models.event'))
    end

    respond_to do |format|
      format.html { redirect_to events_url }
      format.json { head :no_content }
    end
  end

  private

    def carts_empty_for_printing?
      non_empty_carts = Cart.non_empty_carts
      if !non_empty_carts.empty?
        carts = non_empty_carts.map { |c| c.id }
        if carts.size > 1
          flash[:warning] = "Cannot print lists, " + 
                            "because carts #{carts.join(', ')} contain items."
        else
          flash[:warning] = "Cannot print lists, " +
                            "because cart #{carts.join(', ')} contains items."
        end
        false
      else
        true
      end
    end

    def carts_empty?
      non_empty_carts = Cart.non_empty_carts
      if !non_empty_carts.empty?
        carts = non_empty_carts.map { |c| c.id }
        if @event.active
          if carts.size > 1
            flash[:warning] = "Cannot deactivate event, " + 
                              "because carts #{carts.join(', ')} contain items."
          else
            flash[:warning] = "Cannot deactivate event, " +
                              "because cart #{carts.join(', ')} contains items."
          end
        else
          if carts.size > 1
            flash[:warning] = "Cannot activate event, " + 
                              "because carts #{carts.join(', ')} contain items."
          else
            flash[:warning] = "Cannot activate new event, " +
                              "because cart #{carts.join(', ')} contains items."
          end
        end
        false
      else
        true
      end
    end

    def event_params
      params.require(:event)
            .permit(:title,
                    :location, 
                    :event_date, 
                    :active,
                    :information,
                    :max_lists, 
                    :max_items_per_list, 
                    :list_closing_date, 
                    :deduction, 
                    :fee, 
                    :provision, 
                    :delivery_location, 
                    :delivery_date, 
                    :delivery_start_time, 
                    :delivery_end_time, 
                    :collection_location, 
                    :collection_date, 
                    :collection_start_time, 
                    :collection_end_time,
                    :alert_terms,
                    :alert_value)
    end
end
