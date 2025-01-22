# frozen_string_literal: true

require 'spec_helper'

describe 'receipts index page' do
  include ItemsHelper

  let(:event)         { create_active_event }
  let(:seller)        { create_user }
  let(:accepted_list) { create_list(true, event, seller) }
  let(:selling)       { create_selling_and_items(event, accepted_list) }

  describe 'user calls receipt page' do
    before do
      visit receipts_path(locale: :en)
    end

    it "should have title 'Receipts'" do
      expect(page).to have_title 'Secondhand | Receipts'
    end

    it "should have heading 'Receipts'" do
      expect(page).to have_selector('h1', text: 'Receipts')
    end

    it 'should have an input field' do
      expect(page).to have_field('Receipt')
    end
  end

  describe 'user entered valid receipt number' do
    before do
      visit receipts_path(locale: :en)
      fill_in 'Receipt', with: selling.id
      click_button "Search"
    end

    it 'should contain the event title' do
      expect(page).to have_text(event.title)
    end

    it 'should have information about the selling' do
      expect(page).to have_text 'Item'
      expect(page).to have_text 'Description'
      expect(page).to have_text 'Size'
      expect(page).to have_text 'Price'
      expect(page).to have_text 'Total'
    end

    it 'should have a button CSV Export' do
      expect(page).to have_link 'CSV Export'
    end

    it 'should have a button Print to PDF' do
      expect(page).to have_link 'Print to PDF'
    end

    it 'should show the items' do
      expect(page).to have_text list_item_number_for(selling
        .line_items
        .first.item)
      expect(page).to have_text selling.line_items.first.description
      expect(page).to have_text selling.line_items.first.size
      expect(page).to have_text selling.line_items.first.price
      expect(page).to have_text selling.total
    end
  end

  describe 'user enters invalid receipt number' do
    before do
      visit receipts_path(locale: :en)
      fill_in 'Receipt', with: 0
      click_button "Search"
    end

    it 'should show error message' do
      expect(page).to have_text "Sorry, don't find receipt with number 0"
    end
  end

  context 'with existing receipt' do
    before do
      visit receipts_path(locale: :en)
      fill_in 'Receipt', with: selling.id
      click_button 'Search'
    end
    
    describe 'user is pressing button CSV Export' do
      it 'should download receipt as CSV' do
        expect { click_link "CSV Export" }.not_to raise_error
      end
    end

    describe 'user is pressing button Print to PDF' do
      it 'should print receipt to PDF' do
        expect { click_link 'Print to PDF' }.not_to raise_error
      end
    end
  end
end
