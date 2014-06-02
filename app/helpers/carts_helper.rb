module CartsHelper

  def locale_for_type(cart)
    return I18n.t('sales_type') if cart.cart_type == 'SALES'
    return I18n.t('redemption_type') if cart.cart_type == 'REDEMPTION'
  end

  def delete_link_for(transaction, line_item)
    if transaction == 'SALES'
      line_item
    elsif transaction == 'REDEMPTION'
      delete_item_cart_path(line_item)
    end
  end

end
