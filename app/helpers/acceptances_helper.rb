module AcceptancesHelper
  def item_errors(item)
    message = "<div>
                    <div>
                          #{ raw t('errors.template.header', 
                                   count: item.errors.count,
                                   model: t('activerecord.models.item')) }
                        </div>
                <ul>"
    item.errors.full_messages.each do |m|
      message << "<li>#{ raw m }</li>"
    end
    message << "</ul></div>"      
    message.html_safe
  end

  def acceptances_action(list)
    if list.accepted?
      button_to t('.release_list'), accept_acceptance_path(list), 
                   class: "btn btn-warning"
    elsif list.registered?
      link_to t('.acceptance_dialog'), edit_acceptance_path(list)
    else
      t('.not_registered')
    end
  end
end
