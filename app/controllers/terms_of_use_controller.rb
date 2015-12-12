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

    def terms_of_use_all
      TermsOfUse.all
    end

    def conditions
      @conditions ||= Conditions.find(params[:conditions_id])
    end

end
