atom_feed do |feed|
  feed.title I18n.t('.who_registered')
  latest_registration = @users.sort_by(&:updated_at).last

  feed.updated(latest_registration && latest_registration.updated_at)
  @users.each do |user|
    feed.entry(user) do |entry|
      entry.title "#{user.first_name} #{user.last_name}"

      entry.summary type: 'xhtml' do |xhtml|
        xhtml.street user.street
        xhtml.br
        xhtml.town "#{user.zip_code} #{user.town}"
        xhtml.br
        xhtml.phone user.phone
        xhtml.br
        xhtml.email user.email
      end

    end
  end
end
