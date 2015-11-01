class ImporterController < ApplicationController

  VALUES = /:(.*?)=>"(.*?)"/

  skip_before_filter :authorize

  before_filter :load_list, :free_item_capacity, :load_user, :correct_user
  before_filter :ensure_list_can_add_items

  # Select a CSV file containing items to upload
  def file
  end

  # Select items from the uploaded CSV file
  def select
    upload_file
    load_importer
  end

  # Import selected items to the list
  def items
    load_selection
    import_selection or render_select
  end

  private

    def load_list
      @list = List.find(params[:list_id])
    end

    def load_user
      @user = User.find_by(id: @list.user_id)
    end

    def correct_user
      unless !current_user.nil? && (current_user?(@user) || current_user.admin?)
        flash[:notice] = I18n.t('.operation_not_allowed')
        redirect_to(root_path)
      end
    end

    def upload_file
      file = params[:file]
      @filename = File.join("tmp", "#{@user.id}-#{file.original_filename}")
      File.open(@filename, 'w') do |f|
        f.write(file.read)
      end
    end

    def load_file
      @filename = params[:filename]
    end

    def load_importer
      lines = File.readlines(@filename)
      @importer = Importer.new(lines, 
                      formats:   [/^\d+$/, /\S/, /.*/, /^\d+\.[0|5]0?$|^\d+$/], 
                      header:    %w{item description size price}, 
                      col_count: 4)
      @importer.select_rows(load_selection || {})
    end

    def load_selection
      @selection = params[:selection]
    end

    def import_selection
      return false if free_item_capacity < 0
      @selection.each do |id, item|
        @list.items.create!(item_params(id))
      end
      redirect_to user_path(@user)
    end

    def render_select
      load_file
      load_importer
      render :select
    end

    def free_item_capacity
      @capacity = @list.free_item_capacity - (@selection ? @selection.size : 0)
    end

    def ensure_list_can_add_items
      if @list.accepted? || @list.free_item_capacity == 0
        flash[:notice] = I18n.t('.cannot_add_items', 
                       list: @list.list_number) if @list.accepted?
        flash[:notice] = I18n.t('.list_full', 
                       list: @list.list_number) if @list.free_item_capacity == 0
        redirect_to user_path(@user)
      end
    end

    def item_params(id)
      ActionController::Parameters.new(
        Hash[@selection.require(id)
                       .scan(VALUES)
                       .map { |value| [value[0], value[1]] }
            ]).permit(:description, :item_number, :price, :size)
    end
end
