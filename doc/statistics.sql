select e.title, 
       count(distinct u.id) users, 
       count(distinct l.id) lists, 
       count(distinct i.id) items,
       sum(distinct i.price) value,
       avg(i.price) average,
       count(distinct s.id) sellings,
       count(distinct si.id) sold_items,
       sum(distinct siv.price) sold_items_value,
       avg(siv.price) sold_items_average,
       count(distinct r.id) reversals,
       count(distinct ri.id) reversed_items,
       sum(distinct riv.price) reversed_items_value,
       avg(riv.price) reversed_items_average
from events e
  left join lists l
    on l.event_id = e.id
  left join users u
    on l.user_id = u.id
  left join items i
    on i.list_id = l.id
  left join sellings s
    on s.event_id = e.id
  left join line_items si
    on si.selling_id = s.id and si.reversal_id is null
  left join items siv
    on si.item_id = siv.id
  left join reversals r
    on r.event_id = e.id
  left join line_items ri
    on ri.reversal_id = r.id
  left join items riv
    on ri.item_id = riv.id
group by e.title order by e.event_date;

select "-------------------";

select "---- User and List information ----";
select e.id,
       e.title, 
       count(distinct u.id) users, 
       count(distinct l.id) lists, 
       count(i.id) items,
       sum(i.price) value,
       avg(i.price) average
from events e
  left join lists l
    on l.event_id = e.id
  left join users u
    on l.user_id = u.id
  left join items i
    on i.list_id = l.id
group by e.title order by e.event_date;

select "---- Sellings information ----";
select e.id,
       e.title, 
       count(distinct s.id) sellings,
       count(si.id) sold_items,
       sum(siv.price) sold_items_value,
       avg(siv.price) sold_items_average
from events e
  left join sellings s
    on s.event_id = e.id
  left join line_items si
    on si.selling_id = s.id and si.reversal_id is null
  left join items siv
    on si.item_id = siv.id
group by e.title order by e.event_date;

select "---- Reversals information ----";
select e.id,
       e.title, 
       count(distinct r.id) reversals,
       count(ri.id) reversed_items,
       sum(riv.price) reversed_items_value,
       avg(riv.price) reversed_items_average
from events e
  left join reversals r
    on r.event_id = e.id
  left join line_items ri
    on ri.reversal_id = r.id and ri.selling_id is not null
  left join items riv
    on ri.item_id = riv.id
group by e.title order by e.event_date;

