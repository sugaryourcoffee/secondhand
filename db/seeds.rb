# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

Event.delete_all

Event.create(title: 'Herbstboerse Burgthann', event_date: Time.local(2013,"sep",3,9,0,0), location: 'Mittelschule Burgthann', fee: 3.0, deduction: 20.0, provision: 15.0, max_lists: 250, max_items_per_list: 40)

Event.create(title: 'Fruehjahrsboerse Burgthann', event_date: Time.local(2014,"mar",15,9,0,0), location: 'Mittelschule Burgthann', fee: 3.5, deduction: 15.0, provision: 20.0, max_lists: 300, max_items_per_list: 50)

