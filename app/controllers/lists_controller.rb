class ListsController < ApplicationController

  skip_before_filter :authorize, only: [:update, :print_list, :print_labels,
                                        :send_list, :sold_items]

  before_filter :admin_or_operator, only: [:sold_items]

  before_filter :load_user, 
                :correct_user, only: [:print_list, :print_labels, :send_list]

  # GET /lists
  # GET /lists.json
  def index
    load_event
    load_lists
  end

#  def index
#    @event = Event.find_by(active: true)
#
#    params[:search_event_id] ||= @event.id.to_s
#
#    @lists = List.where(List.search_conditions(params))
#                 .order(:event_id)
#                 .order(:list_number)
#                 .paginate(page: params[:page])
#
#    respond_to do |format|
#      format.html # index.html.erb
#      format.json { render json: @lists }
#      format.zip  { send_file List.as_csv_zip, type: 'application/zip' }
#    end
#  end

  def print_list
    load_list
    print_list_to_pdf
  end

#  def print_list
#    @list = List.find(params[:id])
#    respond_to do |format|
#      format.html
#      format.pdf do
#        send_data @list.list_pdf, content_type: Mime::PDF
#      end
#    end
#  end

  def print_labels
    load_list
    print_labels_to_pdf
  end

#  def print_labels
#    @list = List.find(params[:id])
#    respond_to do |format|
#      format.html
#      format.pdf do
#        send_data @list.labels_pdf, content_type: Mime::PDF
#      end
#    end
#  end

  def send_list
    load_list
    send_and_mark_list_as_sent 
    save_list(@user, make_notice(".send_list")) or redirect_to_user
  end

#  def send_list
#    @list = List.find(params[:id])
#    @user = User.find(params[:user_id])
#    respond_to do |format|
#      ListNotifier.received(@list).deliver
#      @list.sent_on = Time.now
#      if @list.save
#        format.html { redirect_to @user, notice: I18n.t('.send_list') }
#      else
#        format.html { redirect_to @user, alert: I18n.t('.send_list_error') }
#      end
#    end
#  end

  def which_list_is_registered_or_closed
    @lists = List.where('user_id > ? or sent_on != ?', 0, nil)
    respond_to do |format|
      format.atom
    end
  end

  # GET /lists/1/sold_items
  def sold_items
    load_list
    load_user_from_list
    statistics_for_sold_items
  end

#  def sold_items
#    @list = List.find(params[:id])
#    @user = @list.user
#    @total, @provision, @fee, @payback = @list.cash_up
#  end

  # GET /lists/1
  # GET /lists/1.json
  def show
    load_list
    show_list_or_download_csv
  end

#  def show
#    @list = List.find(params[:id])
#
#    respond_to do |format|
#      format.html # show.html.erb
#      format.csv { send_data @list.as_csv, 
#                        filename: "#{sprintf("%03d", @list.list_number)}.csv" }
#      format.json { render json: @list }
#    end
#  end

  # GET /lists/new
  # GET /lists/new.json
  def new
    build_list
  end

#  def new
#    @list = List.new
#
#    respond_to do |format|
#      format.html # new.html.erb
#      format.json { render json: @list }
#    end
#  end
  
  def create
    build_list
    reset_sent_on
    save_list(@list, make_notice(".created", model)) or render 'new'
  end

  # POST /lists
  # POST /lists.json
#  def create
#    @list = List.new(list_params) # params[:list])
#
#    respond_to do |format|
#      if @list.save
#        format.html { redirect_to @list, 
#                      notice: I18n.t('.created',
#                                     model: t('activerecord.models.list')) }
#        format.json { render json: @list, status: :created, location: @list }
#      else
#        format.html { render action: "new" }
#        format.json { render json: @list.errors, status: :unprocessable_entity }
#      end
#    end
#  end

  # GET /lists/1/edit
  def edit
    load_list
  end

#  def edit
#    @list = List.find(params[:id])
#  end

  # PUT /lists/1
  # PUT /lists/1.json
  def update
    load_list
    build_list
    reset_sent_on
    save_list(return_url, make_notice(".updated", model)) or render 'edit'
  end

#  def update
#    @list = List.find(params[:id])
#
#    return_url = request.referer.include?("/lists/") ? @list : request.referer
#
#    respond_to do |format|
#      if @list.update_attributes(list_params) # params[:list])
#        format.html { redirect_to return_url, 
#                      notice: I18n.t('.updated',
#                                     model: t('activerecord.models.list')) }
#        format.json { head :no_content }
#      else
#        format.html { render action: "edit" }
#        format.json { render json: @list.errors, status: :unprocessable_entity }
#      end
#    end
#  end

  # DELETE /lists/1
  # DELETE /lists/1.json
  def destroy
    load_list
    reset_sent_on
    @list.destroy
    flash_destroy_notice
    redirect_to lists_path
  end

#  def destroy
#    @list = List.find(params[:id])
#    @list.destroy
#
#    if @list.errors.any?
#      flash[:error] = @list.errors.full_messages.first
#    else
#      flash[:notice] = I18n.t('.destroyed', 
#                              model: t('activerecord.models.list'))
#    end
#
#    respond_to do |format|
#      format.html { redirect_to lists_url }
#      format.json { head :no_content }
#    end
#  end

  private

    def load_lists
      params[:search_event_id] ||= @event.id.to_s if @event

      @lists = List.where(List.search_conditions(params))
                   .order(:event_id)
                   .order(:list_number)
                   .paginate(page: params[:page])

      respond_to do |format|
        format.html
        format.json { render json: @lists }
        format.zip  { send_file List.as_csv_zip(params[:search_event_id]), 
                      type: 'application/zip' }
      end
    end

    def load_list
      @list ||= all_lists.find(params[:id])
    end

    def build_list
      @list ||= all_lists.build
      @list.attributes = list_params
    end

    def save_list(return_url, notice)
      if @list.save
        redirect_to return_url, notice: notice 
      end
    end

    def load_event
      @event ||= Event.find_by(active: true)
    end

    def load_user
      @user ||= User.find(params[:user_id])
    end

    def load_user_from_list
      if @list.user_id && params[:user_id].nil?
        params[:user_id] = @list.user_id
        load_user
      end
    end

    def print_list_to_pdf
      respond_to do |format|
        format.html
        format.pdf do
          send_data @list.list_pdf, content_type: Mime::PDF
        end
      end
    end

    def print_labels_to_pdf
      @list.update(labels_printed_on: Time.now)
      respond_to do |format|
        format.html
        format.pdf do
          send_data @list.labels_pdf, content_type: Mime::PDF
        end
      end
    end

    def show_list_or_download_csv
      respond_to do |format|
        format.html
        format.csv { send_data @list.as_csv, 
                     filename: "#{sprintf("%03d", @list.list_number)}.csv" }
      end
    end

    def send_and_mark_list_as_sent
      ListNotifier.received(@list).deliver
      @list.sent_on = Time.now
#      if @list.save
#        redirect_to @user, notice: notice('.send_list') #I18n.t('.send_list')
#      end
    end

    def return_url
      request.referer.include?("/lists/") ? @list : request.referer
    end

    def redirect_to_user
      redirect_to @user, alert: make_notice('.send_list_error') 
      #I18n.t('.send_list_error') 
    end

    def statistics_for_sold_items
      @total, @provision, @fee, @payback = @list.cash_up
    end

    def list_params
      list_params = params[:list]
      list_params ? list_params.permit(:container, 
                                       :event_id, 
                                       :list_number, 
                                       :registration_code, 
                                       :user_id, 
                                       :sent_on) : { }

#      params.require(:list).permit(:container, :event_id, :list_number, 
#                                   :registration_code, :user_id, :sent_on)
    end

    def flash_destroy_notice
      if @list.errors.any?
        flash[:error] = @list.errors.full_messages.first
      else
        flash[:notice] = make_notice('.destroyed', model) 
        #I18n.t('.destroyed', model: model)
      end
    end

    def make_notice(notice, model=nil)
      model ? I18n.t("#{notice}", model: model) : I18n.t("#{notice}")
    end

    def model
      t('activerecord.models.list')
    end

    def reset_sent_on
      @list.reset_sent_on = current_user?(@list.user)
    end

    def correct_user
      unless current_user?(@user) or current_user.admin?
        redirect_to(root_path) 
      end
    end

    def all_lists
      List.all
    end

end
