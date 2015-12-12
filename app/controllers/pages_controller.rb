class PagesController < ApplicationController

  before_filter :load_terms_of_use

  def new
    build_page
  end

  def create
    build_page
    save_page or render 'new'
  end

  def edit
    load_page
    build_page
  end

  def update
    load_page
    build_page
    save_page or render 'edit'
  end

  def destroy
    load_page
    @page.destroy
    redirect_to @terms_of_use
  end

  def up
    load_page
    move_page(-1) 
    redirect_to @terms_of_use
  end

  def down
    load_page
    move_page(1)
    redirect_to @terms_of_use
  end

  private

    def load_page
      @page ||= page_all.find(params[:id])
    end

    def build_page
      @page ||= page_all.build
      @page.attributes = page_attributes
    end

    def move_page(direction)
      next_page_number = @terms_of_use.next_page(@page.number, direction)
      target_page = @terms_of_use.pages.find_by(number: next_page_number)
      target_page_number = target_page.number
      source_page_number = @page.number
      @page.update(number: 0)
      target_page.number = source_page_number
      target_page.save
      @page.update(number: target_page_number)
    end

    def save_page
      if @page.save
        redirect_to @terms_of_use
      end
    end

    def page_attributes
      page_attributes = params[:page]
      page_attributes ? page_attributes.permit(:number, :title, :content) 
                      : { number: @page.number || @terms_of_use.next_free }
    end

    def load_terms_of_use
      @terms_of_use ||= TermsOfUse.find(params[:terms_of_use_id])
    end

    def page_all
      @terms_of_use.pages
    end
end
