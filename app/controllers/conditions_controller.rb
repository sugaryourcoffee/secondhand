class ConditionsController < ApplicationController

  def index
    load_conditions
  end

  def show
    load_condition
  end

  def new
    build_condition
  end

  def create
    build_condition
    save_condition or render 'new'
  end

  def edit
    load_condition
    build_condition
  end

  def update
    load_condition
    build_condition
    save_condition or render 'edit'
  end

  def destroy
    load_condition
    @condition.destroy
    redirect_to conditions_path
  end

  def copy
    copy_condition or redirect_to conditions_path
  end

  def activate
    load_condition
    activate_condition 
    redirect_to conditions_path
  end

  private

    def load_conditions
      @conditions ||= conditions_all
    end

    def load_condition
      @condition ||= conditions_all.find(params[:id])
    end

    def build_condition
      @condition ||= conditions_all.build
      @condition.attributes = condition_params
    end

    def save_condition
      if @condition.save
        redirect_to @condition
      end
    end

    def copy_condition
      @condition = conditions_all.find(params[:id]).clone_with_associations
      redirect_to edit_condition_path @condition
    end

    def activate_condition
      unless @condition.active?
        active = conditions_all.find_by(active: true)
        active.toggle!(:active) if active
      end
      @condition.toggle!(:active)
    end

    def condition_params
      condition_params = params[:conditions]
      condition_params ? condition_params.permit(:version) : {}
    end

    def conditions_all
      Conditions.all
    end

end
