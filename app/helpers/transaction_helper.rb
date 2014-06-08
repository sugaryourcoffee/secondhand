module TransactionHelper

  def show(transaction, opts = {})
    transaction_name = transaction.class.name.downcase

    opts[:title]      ||= I18n.t("shared.#{transaction_name}.title")
    opts[:heading]    ||= I18n.t("shared.#{transaction_name}.header", 
                                 id: transaction.id)
    opts[:subheading] ||= active_event.title if active_event
    opts[:link_name]  ||= I18n.t("shared.#{transaction_name}.overview")
    opts[:link]       ||= lambda { :back }

    render "shared/transaction_show_page",
      transaction: transaction,
      title:       opts[:title],
      heading:     opts[:heading],
      subheading:  opts[:subheading],
      link_name:   opts[:link_name],
      link:        opts[:link]

  end

  def status_for(transaction, opts = {}) 
    transaction_name = transaction.class.name.downcase

    opts[:status_header] ||= I18n.t("shared.#{transaction_name}.status_header")

    render "shared/transaction_status",
      transaction: transaction,
      status_header: opts[:status_header]

  end

  def items_for(transaction, opts = {}) 
    transaction_name = transaction.class.name.downcase

    opponent = "#{transaction_name}_opponent"

    opts[:opponent_title] ||= I18n.t("shared.#{transaction_name}.opponent")
    opts[:opponent] ||= lambda do |line_item| 
      o = line_item.send(opponent)
      if o.nil?
        '-'
      else
        o.id
      end
    end

    render "shared/items",
      transaction: transaction,
      number:      lambda { |line_item| list_item_number_for(line_item.item) },
      opponent_title: opts[:opponent_title],
      opponent:       opts[:opponent],
      description: lambda { |line_item| line_item.description },
      size:        lambda { |line_item| line_item.size },
      price:       lambda { |line_item| line_item.price }

  end
end
