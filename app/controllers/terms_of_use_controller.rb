class TermsOfUseController < ApplicationController

  def new
    build_terms_of_use
  end

  def create
    build_terms_of_use
    save_terms_of_use or render 'new'
  end

  def edit
    load_terms_of_use
    build_terms_of_use
  end

  def update
    load_terms_of_use
    build_terms_of_use
    save_terms_of_use or render 'edit'
  end

  def show
    load_terms_of_use
  end

  def copy
    copy_terms_of_use and render 'edit' or redirect_to @conditions
  end

  def destroy
    load_terms_of_use
    @terms_of_use.destroy
    redirect_to condition_path(@conditions)
  end

  def display
    load_user
    load_buttons if load_next_page_and_page_count
  end

  def accept
    accept_terms_of_use or redirect_to terms_of_use_path
  end

  private

    def build_terms_of_use
      @terms_of_use ||= conditions.terms_of_uses.build
      @terms_of_use.attributes = terms_of_use_params
    end

    def save_terms_of_use
      if @terms_of_use.save
        redirect_to @terms_of_use
      end
    end

    def load_terms_of_use
      @terms_of_use ||= terms_of_use_all.find(params[:id])
      @conditions ||= @terms_of_use.conditions
    end

    def terms_of_use_params
      terms_of_use_params = params[:terms_of_use]
      terms_of_use_params ? terms_of_use_params.permit(:locale) : {}
    end

    def copy_terms_of_use
      @terms_of_use = terms_of_use_all.find(params[:id]).clone_with_associations
      @conditions = @terms_of_use.conditions 
    end

    def load_user
      @user = current_user
      event = Event.find_by(active: true)
      @user.update!(terms_of_use: nil) if event && 
                                          @user &&
                                          @user.terms_of_use &&
                                          event.created_at > @user.terms_of_use
    end

    def load_next_page_and_page_count
#      terms_of_use = TermsOfUse.find_by(active: true)
      @page = if terms_of_use.nil?
                nil
              else 
                number = (params[:page] || 1).to_i + 
                         (params[:direction] || 0).to_i
                terms_of_use.pages.find_by(number: number)
              end
      @count = terms_of_use.pages.count unless terms_of_use.nil?
    end

    def load_buttons
      @buttons = []
      @buttons << :next   if @page.number < @count
      @buttons << :back   if @page.number > 1
      if @page.number == @count
        @buttons << (@user && @user.terms_of_use.nil? ? :accept : :close)
      end
    end

    def accept_terms_of_use
      user = current_user
      if user && user.update(terms_of_use: Time.now)
        sign_in user
        redirect_to user
      end
    end

    def terms_of_use_all
      TermsOfUse.all
    end

    def conditions
      @conditions ||= Conditions.find(params[:conditions_id])
    end

end
