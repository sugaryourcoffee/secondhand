shopping_list = [
  ["Carton of goat milk", 1],
  ["Head of garlic2", 2],
  ["Choclate bar", 9]
]

Prawn::Document.generate("shopping_list.pdf") do
  table([[ "Item", "Quantity" ], *shopping_list]) do |t|
    t.header = true
    t.row_colors = [ "aaaaff", "aaffaa", "ffaaaa" ]
    t.row(0).style background_color: '448844', text_color: 'ffffff'
    t.columns(1).align = :right
  end
end
