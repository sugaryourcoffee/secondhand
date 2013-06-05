class ListsController < ApplicationController

  skip_before_filter :authorize, only: [:update, :print_list, :print_labels]

  before_filter :correct_user, only: [:print_list, :print_labels]

  # GET /lists
  # GET /lists.json
  def index
    @lists = List.order(:event_id).order(:list_number)
                 .paginate(page: params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @lists }
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

  # GET /lists/1
  # GET /lists/1.json
  def show
    @list = List.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
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
    @list = List.new(params[:list])

    respond_to do |format|
      if @list.save
        format.html { redirect_to @list, 
                      notice: 'List was successfully created.' }
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

    return_url = request.referer.include?("/users/") ? request.referer : @list

    respond_to do |format|
      if @list.update_attributes(params[:list])
        format.html { redirect_to return_url, 
                      notice: 'List was successfully updated.' }
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
      flash[:notice] = "List #{@list.list_number} deleted"
    end

    respond_to do |format|
      format.html { redirect_to lists_url }
      format.json { head :no_content }
    end
  end

  private

  def correct_user
    @user = User.find(params[:user_id])
    redirect_to(root_path) unless current_user?(@user) or current_user.admin?
  end

end
