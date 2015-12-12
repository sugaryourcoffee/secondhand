module ConditionsHelper

  def activate_locale(conditions)
    conditions.active? ? t('.deactivate') : t('.activate')
  end

end
