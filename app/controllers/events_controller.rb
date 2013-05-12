class EventsController < ApplicationController
  # GET /events
  # GET /events.json
  def index
    @events = Event.paginate(page: params[:page])

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
    @event = Event.new(params[:event])

    respond_to do |format|
      if @event.save
        create_lists(@event)
        format.html { redirect_to @event, notice: 'Event was successfully created.' }
        format.json { render json: @event, status: :created, location: @event }
      else
        format.html { render action: "new" }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /events/1
  # PUT /events/1.json
  def update
    @event = Event.find(params[:id])

    params[:max_lists] = create_lists(@event, params[:event][:max_lists].to_i)

    respond_to do |format|
      if @event.update_attributes(params[:event])
        format.html { redirect_to @event, notice: 'Event was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  def create_lists(event, max_lists=event.max_lists)
    lists = List.find_all_by_event_id(event.id) || []
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

  def create_registration_codes(numbers, codes, size)
    numbers.each do |number|
      code = number.to_s.crypt("#{Random.new_seed}")[1..size]
      redo if codes.find_index(code)
      codes.insert(number-1, code)
    end
    codes
  end

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

    respond_to do |format|
      format.html { redirect_to events_url }
      format.json { head :no_content }
    end
  end
end
