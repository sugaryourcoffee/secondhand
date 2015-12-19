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

  def index_acceptances_action(list)
    if list.accepted?
      if list.has_sold_items?
        if current_user.admin?
          button_to t('.release_list'), accept_acceptance_path(list),
                       class: "btn btn-warning"
        else 
          t('.list_has_sold_items')
        end
      else
          button_to t('.release_list'), accept_acceptance_path(list),
                       class: "btn btn-warning"
      end
    elsif list.registered?
      link_to t('.acceptance_dialog'), edit_acceptance_path(list)
    else
      t('.not_registered')
    end
  end

  def edit_acceptances_action(list)
    if @list.accepted?
      button_to t('.revoke_acceptance'), accept_acceptance_path(list), 
        class: "btn btn-warning" unless list.has_sold_items?
    else
      button_to t('.accept_list'), accept_acceptance_path(list), 
        class: "btn btn-primary"
    end
  end

  def indicate_item_change(item, list)
    '>>>' if (list.sent_on.nil? || 
              item.updated_at > list.sent_on) && 
             (list.labels_printed_on.nil? || 
              item.updated_at > list.labels_printed_on)
  end
end
