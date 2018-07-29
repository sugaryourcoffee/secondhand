module UsersHelper

  # Returns the Gravatar (http://gravatar.com/) for the given user
  def gravatar_for(user, options = { size: 50 })
    gravatar_id = Digest::MD5::hexdigest(user.email.downcase)
    size = options[:size]
    gravatar_url = "https://secure.gravatar.com/avatar/#{gravatar_id}.png"+
                   "?s=#{size}"
    image_tag(gravatar_url, alt: name_for(user, :last_name, :first_name, ','),
              class: "gravatar")
  end

  def name_for(user, first = :first_name, second = :last_name, separator = "")
    if user.active?
      name  = first.empty?  ? "" : user.send(first)
      name += separator
      name += second.empty? ? "" : " #{user.send(second)}"
      name
    else
      "Anonymous"
    end
  end

  def address_for(user)
    "#{user.street}\n#{user.zip_code} #{user.town}\n#{user.country}"
  end

  def link_to_list_forwarding(user)
    message = { email:    user.email, 
                category: I18n.t('static_pages.contact.category_selections')[1],
                subject:  'Listenweitergabe',
                message:  "#{I18n.t('.user_name')}: #{user.email}\n"+
                          "#{I18n.t('.list_number')}:\n"+
                          "#{I18n.t('.registration_code')}:\n"+
                          "#{I18n.t('.forwarding_to')}:" }

    link_to I18n.t('.contact'), contact_path(message: message)
  end

  def link_to_help
    message = { category: I18n.t('static_pages.contact.category_selections')[2],
                subject:  I18n.t('static_pages.contact.help') }
    link_to I18n.t('.contact'), contact_path(message: message)
  end

end
