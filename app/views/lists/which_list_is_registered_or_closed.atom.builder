atom_feed do |feed|
  feed.title I18n.t('.which_list')
  latest_list = @lists.sort_by(&:updated_at).last

  feed.updated(latest_list && latest_list.updated_at)
  @lists.each do |list|
    feed.entry(list) do |entry|
      if list.sent_on
        entry.title I18n.t('.list_closed', list_number: list.list_number)
      else
        entry.title I18n.t('.list_registered', list_number: list.list_number)
      end

      entry.summary type: 'xhtml' do |xhtml|
        xhtml.user "#{list.user.first_name} #{list.user.last_name}"
        xhtml.br
        if list.sent_on
          xhtml.sent_on I18n.t('.list_closed_on', 
                               time: time_ago_in_words(list.sent_on))
        else
          xhtml.registered I18n.t('.list_registered_on', 
                               time: time_ago_in_words(list.created_at))
        end
        xhtml.br
      end

    end
  end
end
