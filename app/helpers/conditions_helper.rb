module ConditionsHelper

  def activate_locale(conditions)
    conditions.active? ? t('.deactivate') : t('.activate')
  end

  def new_language_link(conditions)
    if conditions.available_locales.empty?
      t('.no_more_languages')
    else
      link_to t('.new_locale'), new_terms_of_use_path(conditions_id: @condition)
    end
  end

  def language_selections_for_edit(terms_of_use)
    terms_of_use.conditions
                .available_locales << LANGUAGES.rassoc(terms_of_use.locale) 
  end

  def edit_language_link(terms_of_use)
    link_to_unless terms_of_use.conditions.available_locales.empty?, 
                   t('.edit'), 
                   edit_terms_of_use_path(terms_of_use)
  end

  def copy_language_link(terms_of_use)
    link_to_unless terms_of_use.conditions.available_locales.empty?,
                   t('.copy'), 
                   copy_terms_of_use_path(terms_of_use)

  end

end
