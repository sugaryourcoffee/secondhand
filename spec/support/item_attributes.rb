def item_attributes(override = {})
  {
    item_number: 1,
    description: "Item of the list",
    size:        "XXL",
    price:       22.5
  }.merge(override)
end
