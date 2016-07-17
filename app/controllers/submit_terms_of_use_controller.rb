class SubmitTermsOfUseController < ApplicationController

  skip_before_filter :authorize

  def display
    load_terms_of_use
    load_next_page
  end

  def accept
    accept_terms_of_use or redirect_to display_terms_of_use_path
  end

  private

    def load_terms_of_use
      conditions = Conditions.find_by(active: true)
      @terms_of_use = conditions.terms_of_uses
                                .find_by(locale: I18n.locale) if conditions
    end

    def load_next_page
      unless @terms_of_use.nil? || @terms_of_use.pages.empty?
        @page = @terms_of_use.pages.find_by(number: next_page)
        @buttons = create_buttons(@terms_of_use.first_page, 
                                  @terms_of_use.last_page)
        @count = @terms_of_use.pages.count
      end
    end

    def create_buttons(first_page, last_page)
      buttons = []
      buttons << :next if @page.number < last_page
      buttons << :back if @page.number > 1  
      if @page.number == last_page
        if current_user
          buttons << (current_user.terms_of_use.nil? ? :accept : :close)
        else
          buttons << :close
        end
      end
      buttons
    end

    def next_page
      @terms_of_use.next_page((params[:page] || 1).to_i, 
                               params[:direction].to_i)
    end

    def accept_terms_of_use
      user = current_user
      if user && user.update(terms_of_use: Time.now)
        sign_in user
        redirect_to user
      end
    end

end
