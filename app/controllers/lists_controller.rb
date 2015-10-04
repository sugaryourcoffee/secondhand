class ListsController < ApplicationController

  skip_before_filter :authorize, only: [:update, :print_list, :print_labels,
                                        :send_list, :sold_items]

  before_filter :admin_or_operator, only: [:sold_items]

  before_filter :correct_user, only: [:print_list, :print_labels, :send_list]

  # GET /lists
  # GET /lists.json
  def index
    @event = Event.find_by(active: true) # find_by_active(true)

    params[:search_event_id] ||= @event.id.to_s

    @lists = List.where(List.search_conditions(params))
                 .order(:event_id)
                 .order(:list_number)
                 .paginate(page: params[:page])

#    @lists = List.order(:event_id).order(:list_number)
#                 .paginate(page: params[:page], 
#                           conditions: List.search_conditions(params))

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @lists }
      format.zip  { send_file List.as_csv_zip, type: 'application/zip' }
    end
  end

  def print_list
    @list = List.find(params[:id])
    respond_to do |format|
      format.html
      format.pdf do
        send_data @list.list_pdf, content_type: Mime::PDF
      end
    end
  end

  def print_labels
    @list = List.find(params[:id])
    respond_to do |format|
      format.html
      format.pdf do
        send_data @list.labels_pdf, content_type: Mime::PDF
      end
    end
  end

  def send_list
    @list = List.find(params[:id])
    @user = User.find(params[:user_id])
    respond_to do |format|
      ListNotifier.received(@list).deliver
      @list.sent_on = Time.now
      if @list.save
        format.html { redirect_to @user, notice: I18n.t('.send_list') }
      else
        format.html { redirect_to @user, alert: I18n.t('.send_list_error') }
      end
    end
  end

  def which_list_is_registered_or_closed
    @lists = List.where('user_id > ? or sent_on != ?', 0, nil)
    respond_to do |format|
      format.atom
    end
  end

  # GET /lists/1/sold_items
  def sold_items
    @list = List.find(params[:id])
    @user = @list.user
    @total, @provision, @fee, @payback = @list.cash_up
  end

  # GET /lists/1
  # GET /lists/1.json
  def show
    @list = List.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.csv { send_data @list.as_csv, 
                        filename: "#{sprintf("%03d", @list.list_number)}.csv" }
      format.json { render json: @list }
    end
  end

  # GET /lists/new
  # GET /lists/new.json
  def new
    @list = List.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @list }
    end
  end

  # GET /lists/1/edit
  def edit
    @list = List.find(params[:id])
  end

  # POST /lists
  # POST /lists.json
  def create
    @list = List.new(list_params) # params[:list])

    respond_to do |format|
      if @list.save
        format.html { redirect_to @list, 
                      notice: I18n.t('.created',
                                     model: t('activerecord.models.list')) }
        format.json { render json: @list, status: :created, location: @list }
      else
        format.html { render action: "new" }
        format.json { render json: @list.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /lists/1
  # PUT /lists/1.json
  def update
    @list = List.find(params[:id])

    return_url = request.referer.include?("/lists/") ? @list : request.referer

    respond_to do |format|
      if @list.update_attributes(list_params) # params[:list])
        format.html { redirect_to return_url, 
                      notice: I18n.t('.updated',
                                     model: t('activerecord.models.list')) }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @list.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /lists/1
  # DELETE /lists/1.json
  def destroy
    @list = List.find(params[:id])
    @list.destroy

    if @list.errors.any?
      flash[:error] = @list.errors.full_messages.first
    else
      flash[:notice] = I18n.t('.destroyed', 
                              model: t('activerecord.models.list'))
    end

    respond_to do |format|
      format.html { redirect_to lists_url }
      format.json { head :no_content }
    end
  end

  private

    def list_params
      params.require(:list).permit(:container, :event_id, :list_number, 
                                   :registration_code, :user_id, :sent_on)
    end

    def correct_user
      @user = User.find(params[:user_id])
      redirect_to(root_path) unless current_user?(@user) or current_user.admin?
    end

end
