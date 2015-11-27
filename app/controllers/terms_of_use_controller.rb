class TermsOfUseController < ApplicationController

  skip_before_filter :authorize

  def display
    load_user
    load_buttons if load_next_page_and_page_count
  end

  def accept
    accept_terms_of_use or redirect_to terms_of_use_path
  end

  private

    def load_user
      @user = current_user
      event = Event.find_by(active: true)
      @user.update!(terms_of_use: nil) if event && 
                                          @user &&
                                          @user.terms_of_use &&
                                          event.created_at > @user.terms_of_use
    end

    def load_next_page_and_page_count
      terms_of_use = TermsOfUse.find_by(active: true)
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

end
