class Statistics

  def summary
    summary = []
    sellings = selling
    reversals = reversal
    general.each_with_index do |g, i|
      summary[i] = g.merge(sellings[i]).merge(reversals[i])
    end
    summary
  end

  def general
    prepare ActiveRecord::Base.connection.execute(
      "select 
         e.id,
         e.title, 
         e.event_date,
         count(distinct u.id) sellers, 
         count(distinct l.id) lists, 
         count(i.id) items,
         avg(i.price) average_item_value,
         sum(i.price) total_list_value,
         (sum(i.price)*1.0)/count(distinct l.id) average_list_value
       from events e
         left join lists l
           on l.event_id = e.id
         left join users u
           on l.user_id = u.id
         left join items i
           on i.list_id = l.id
       group by e.title order by e.event_date")
  end

  def general_ar
    Event.includes({:lists =>  [:items] }, :users)
         .select("events.id,
                  events.title,
                  events.event_date,
                  count(distinct users.id) as sellers,
                  count(distinct lists.id) as lists,
                  count(items.id) as items,
                  avg(items.price) as average_item_value,
                  sum(items.price) as total_list_value,
                  (sum(items.price) * 1.0)/count(distinct lists.id) " + 
                  "as average_list_value")
          .joins("left outer join `lists` on lists.event_id = events.id " +
                 "left outer join `users` on lists.user_id = users.id " +
                 "left outer join `items` on items.list_id = lists.id")
          .group("events.title")
          .order("events.event_date")
  end

  def selling
    prepare ActiveRecord::Base.connection.execute(
      "select 
         e.id,
         e.title, 
         e.event_date,
         count(distinct s.id) sellings,
         count(si.id) sold_items,
         sum(siv.price) total_selling_value,
         avg(siv.price) average_sold_item_value,
         (sum(siv.price)*1.0)/count(distinct s.id) average_selling_value
       from events e
         left join sellings s
           on s.event_id = e.id
         left join line_items si
           on si.selling_id = s.id and si.reversal_id is null
         left join items siv
           on si.item_id = siv.id
       group by e.title order by e.event_date")
  end

  def reversal
    prepare ActiveRecord::Base.connection.execute(
      "select 
         e.id,
         e.title, 
         e.event_date,
         count(distinct r.id) reversals,
         count(ri.id) reversed_items,
         sum(riv.price) total_reversal_value,
         avg(riv.price) average_reversed_item_value,
         (sum(riv.price)*1.0)/count(distinct r.id) average_reversal_value
       from events e
         left join reversals r
           on r.event_id = e.id
         left join line_items ri
           on ri.reversal_id = r.id
         left join items riv
           on ri.item_id = riv.id
       group by e.title order by e.event_date")
  end

  private

    def prepare(result)
      if result.class.to_s == "Mysql2::Result"
        fields = result.fields
        transformed = []
        result.each do |r| 
          mapping = {}
          fields.zip(r.entries).each do |k, v|
            mapping[k] = v
          end
          transformed << mapping
        end 
        transformed
      else
        result
      end
    end

end
