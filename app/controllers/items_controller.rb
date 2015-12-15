class ItemsController < ApplicationController

  skip_before_filter :authorize, 
                 only: [:index, :new, :create, :destroy, :show, :edit, :update]

  before_filter :load_user_and_list, :correct_user

  def index
    load_items
  end

  def new
    redirect_if_list_accepted_or_full or new_item
  end

  def create
    build_item
    save_item or render :new
  end

  def show
    load_item
  end

  def edit
    load_item
    redirect_if_list_accepted or build_item
  end

  def update
    load_item
    build_item
    update_item
  end

  def destroy
    load_item
    destroy_item or redirect_to_user
  end

  private

    def load_items
      @items ||= @list.items.order(:item_number)
    end

    def load_item
      @item ||= @list.items.find(params[:id])
    end

    def new_item
      @item = Item.new
    end

    def build_item
      @item ||= @list.items.build
      @item.attributes = item_params
    end

    def save_item
      if @item.save
        reset_list_sent_on
        flash[:success] = I18n.t('.created', 
                                 model: t('activerecord.models.item'))
        if params[:commit] == I18n.t('.items.form.create_and_new')
          redirect_to new_user_list_item_path(@user, @list)
        else
          redirect_to user_list_items_path(@user, @list)
        end
      end 
    end

    def update_item
      respond_to do |format|
        if @item.save
          reset_list_sent_on
          return_url = request.referer.include?("/items/") ? 
                       user_list_items_path(@user, @list) : request.referer
          format.html { redirect_to return_url, 
                        notice: I18n.t('.updated', 
                                       model: t('activerecord.models.item')) }
          format.js { redirect_to return_url }
        else
          if request.referer.include?("/items/")
            format.html { render action: 'edit' } 
          else
            format.js { redirect_to request.referer }
          end
        end  
      end
    end

    def destroy_item
      unless @list.accepted_on
        @item.destroy
        reset_list_sent_on
        flash[:success] = I18n.t('.destroyed', 
                                 model: t('activerecord.models.item'))
        redirect_to user_list_items_path(@user, @list)
      end
    end

    def redirect_if_list_accepted_or_full
      if @list.max_items_per_list?
        flash[:warning] = I18n.t('.list_full', list_number: @list.list_number)
        redirect_to root_path
      elsif @list.accepted_on
        flash[:warning] = I18n.t('.list_accepted_new', 
                                 list_number: @list.list_number)
        redirect_to current_user
      end
    end

    def redirect_if_list_accepted
      if @list.accepted_on
        flash[:warning] = I18n.t('.list_accepted_edit', 
                                 list_number: @list.list_number)
        redirect_to current_user
      end
    end

    def redirect_to_user
      flash[:warning] = I18n.t('.list_accepted_destroy', 
                               list_number: @list.list_number)
      redirect_to current_user
    end

    def reset_list_sent_on
      if @list.user == @user and @list.sent_on
        @list.sent_on = nil
        @list.save
      end
    end

    def item_params
      item_params = params[:item]
      item_params ? item_params.permit(:description, 
                                       :item_number, 
                                       :price, 
                                       :size) : {}
    end

    def correct_user
      unless @list.user == @user or current_user.admin?
        flash[:warning] = I18n.t('.list_not_assigned', 
                                 model: t('activerecord.models.item'))
        redirect_to(root_path)
      end
    end

    def load_user_and_list
      @user = User.find(params[:user_id])
      @list = List.find(params[:list_id])
    end
end
