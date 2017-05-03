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

  # Retrieves a sorted array of list revenues. This can be used in conjunction
  # with quartile.
  #
  # stat = Statistics.new
  # stat.quartile(stat.list_revenues)
  def list_revenues
    (prepare ActiveRecord::Base.connection.execute(
      "select * from (select sum(i.price) sum from lists l
                        join items i on i.list_id = l.id
                        join line_items li on li.item_id = i.id and
                                              li.reversal_id is null
                      group by l.id) x
       order by x.sum")
    ).map { |x| x["sum"] }
  end

  # Retrieves a sorted array of list revenues ordered by event. This can be 
  # used in conjunction with quartile.
  #
  # stat = Statistics.new
  # result = stat.event_list_revenues
  # result.map { |k,v| stat.quartile(v["values"]) }
  def event_list_revenues
    query = prepare ActiveRecord::Base.connection.execute(
      "select * from (select e.id id, e.title title , sum(i.price) sum 
                      from events e
                        join lists l on l.event_id = e.id
                        join items i on i.list_id = l.id
                        join line_items li on li.item_id = i.id and
                                              li.reversal_id is null
                      group by l.id) x
       order by x.sum")

    result = {}
    
    query.map do |q|
      if result[q["id"]].nil?
        result[q["id"]] = { "title" => q["title"], "values" => [q["sum"]] }
      else
        result[q["id"]]["values"] << q["sum"]
      end
    end
    
    result.each { |k,v| result[k]["values"] = v["values"].sort }
    Hash[result.sort]
  end

  # Returns an array of hashes with the count of lists without sold items per
  # event.
  #
  # stat = Statistics.new
  # stat.lists_revenue_zero
  #
  # => [{"id"=>6, "title"=>"Herbstbörse Burgthann 2013", 
  #      "without_sold_items"=>204}]
  def lists_revenue_zero
    prepare ActiveRecord::Base.connection.execute(
      "select e.id, e.title, count(distinct l.id) without_sold_items
         from events e
           left join lists l on l.event_id = e.id
         where l.id not in 
           (select l.id id from lists l 
            join items i on i.list_id = l.id
            join line_items li on li.item_id = i.id)
        group by e.id")
  end

  # Returns an array of hashes with the count of lists below the provided value.
  #
  # stat = Statistics.new
  # stat.lists_revenue_below(20)
  #
  # => [{"id"=>6, "title"=>"Herbstbörse Burgthann 2013", 
  #      "below_min_revenue"=>3}]
  def lists_revenue_below(revenue = 20)
    prepare ActiveRecord::Base.connection.execute(
      "select e.id, e.title, count(l.id) below_min_revenue
         from lists l
         left join events e on l.event_id = e.id
         join (select l.id, sum(i.price) total
                 from lists l
                 join items i on i.list_id = l.id
                 join line_items li 
                   on li.item_id = i.id and li.reversal_id is null
               group by l.id) x on x.id = l.id and x.total < #{revenue}
       group by e.id")
  end

  # Returns an array of hashes with the count of revenues
  #
  # stat = Statistics.new
  # stat.lists_revenue_frequency
  #
  # => [{"frequency"=>2, "sum"=>1}, {"frequency"=>2, "sum"=>5}]
  def lists_revenue_frequency
    prepare ActiveRecord::Base.connection.execute(
      "select count(x.sum) frequency, x.sum from (select l.id, sum(i.price) sum 
         from lists l 
           join items i on i.list_id = l.id 
           join line_items li 
             on li.item_id = i.id and li.reversal_id is null 
         group by l.id) x 
       group by x.sum")
  end

  # Returns an array of hashes with histogram data of revenues
  #
  # stat = Statistics.new
  # stat.lists_revenue_histogram
  #
  # => ["0.5" => {"sum_range"=>"0.5 - 172.5", "frequency"=>2}]
  # 
  # The result can be used with Histogram to create a SVG string that can be
  # used in a html file
  #
  # hist = Histogram.new
  # hist.to_svg(stat.lists_revenue_histogram)
  def lists_revenue_histogram(bar_count = nil)
    stats = quartile(list_revenues)

    bar_count ||= bars(stats[:count])

    r = ranges(stats, bar_count)

    q = prepare ActiveRecord::Base.connection.execute(
      "select t.sum_range as sum_range, count(*) as frequency 
         from (select case 
                 #{r.values.join(' ')}
               end as sum_range 
               from (select l.id, sum(i.price) sum 
                       from lists l 
                         join items i 
                           on i.list_id = l.id 
                         join line_items li 
                           on li.item_id = i.id and li.reversal_id is null 
                     group by l.id) x) t 
       group by t.sum_range")

    q.map { |q|
      { (q["sum_range"] || "0").scan(/^\d+\.\d+|^\d+/).first.to_f => q }
    }.sort_by { |k, v| k.keys }
  end


  # Extracts the x-values of the lists_revenues_histogram result
  def histogram_x_values(hist)
    hist.map { |h| h.keys }.flatten
  end

  # Extracts the y-values of the lists_revenues_histogram result
  def histogram_y_values(hist)
    hist.map { |h| h.values }.flatten
  end

  # Returns an array of hashes with min and max revenues and the count of 
  # sellings.
  #
  # stat = Statistics.new
  # stat.lists_revenue_min_max_count
  #
  # => [{"min"=>2, "max"=>100, "count"=>5}]
  def lists_revenue_min_max_count
    prepare ActiveRecord::Base.connection.execute(
      "select min(x.sum) min, max(x.sum) max, count(x.sum) count
         from (select l.id, sum(i.price) sum 
                 from lists l 
                   join items i 
                     on i.list_id = l.id 
                   join line_items li 
                     on li.item_id = i.id and li.reversal_id is null 
                group by l.id) x")
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

  # Calculates quartiles and expects a sorted array. This can be used together
  # with list_revenues
  #
  # stat = Statistics.new
  # stat.quartile(stat.list_revenues)
  #
  # => {:count=>11, :min=>1, :max=>1033.0, :q2=>12.0, :q1=>2.5, :q3=>556.5}
  def quartile(vector)
    count = vector.count

    result = { count: count,
               min:   vector.min,
               max:   vector.max,
               q2:    median(vector) }
     
    if count/4 == count/4.0
       result[:q1] = (vector[count/4  -1] + vector[count/4  ])/2
       result[:q3] = (vector[count/4*3-1] + vector[count/4*3])/2
    else
       result[:q1] = vector[(count/4.0  ).floor]
       result[:q3] = vector[(count/4.0*3).floor]
    end

    result
  end

  def median(vector)
    count = vector.count
    
    if count.odd?
      vector[count/2]
    else
      (vector[count/2 - 1] + vector[count/2])/2.0
    end
  end

  def bars(count)
    case count
    when   0..49  then  6
    when  50..99  then  8
    when 100..249 then 10
    else 15
    end
  end

  def ranges(stats, bars = 10, bottom = 0.5)
    range = ((stats[:max] - stats[:min]) / bars).floor

    lower = bottom
    upper = lower + range

    ranges = {}

    key = "lower - upper"
    query = "when x.sum between lower and upper then 'lower - upper'"

    1.upto(bars) do |r|
      ranges[key.gsub(/lower/, lower.to_s).gsub(/upper/, upper.to_s)] = 
        query.gsub(/lower/, lower.to_s).gsub(/upper/, upper.to_s)
      lower = upper + bottom
      upper = lower + range
    end

    ranges
  end

  private

    # TODO: This is a hack. As I am not able to use ActiveRecord to create the
    #       query I have to check whether the result set comes from MySQL. If
    #       so I transform the result set into an array of hashes. As soon as
    #       I find out how to do the query with ActiveRecord this has to be
    #       refactored!
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
