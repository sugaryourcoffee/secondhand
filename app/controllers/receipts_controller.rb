# frozen_string_literal: true

# Provides actions to show, print and export a selling receipt. A selling
# receipt is from a buyer's point of view a purchase receipt. We use
# sellings to obtain the receipts.
class ReceiptsController < ApplicationController
  skip_before_filter :authorize

  def index
    @receipt = Selling.find_by(id: params[:search_receipt_id])
    respond_to do |format|
      if @receipt
        format.html { @receipt }
      else
        if params[:search_receipt_id]
          flash.now[:warning] = I18n.t('.receipts.index.no_receipt_number', 
                                       receipt_id: params[:search_receipt_id])
        end
        format.html
      end
    end
  end

  def export
    load_receipt
    export_receipt
  end

  def print
    load_receipt
    print_receipt
  end

  private 

  def load_receipt
    @receipt = Selling.find(params[:id])
  end

  def export_receipt
    respond_to do |format|
      format.csv do
        send_data @receipt.as_csv, 
          filename: "#{I18n.t('.receipts.filename', 
                              receipt_id: @receipt.id)}.csv"
      end
    end
  end

  def print_receipt
    respond_to do |format|
      format.pdf do
        send_data @receipt.to_pdf('Verkauf', false), content_type: Mime::PDF
      end
    end
  end
end
