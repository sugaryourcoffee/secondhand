require 'spec_helper'

describe 'Role authentication' do
  
  describe 'as regualar user' do
    let(:user) { FactoryGirl.create(:user) }
    let(:list) { FactoryGirl.create(:list, user: user) }

    before { sign_in user }

    describe 'in the acceptances controller' do
      
      describe 'visiting the acceptances page' do
        before { get acceptances_path(locale: :en) }
        specify { expect(response).to redirect_to(root_path(locale: :en)) }
      end

      describe 'accept list' do
        before { post accept_acceptance_path(list, locale: :en) }
        specify { expect(response).to redirect_to(root_path(locale: :en)) }
      end

      describe 'edit list' do
        before { get edit_list_acceptance_path(list, locale: :en) }
        specify { expect(response).to redirect_to(root_path(locale: :en)) }
      end

    end

    describe 'in the carts controller' do

      describe 'visiting the carts page' do
        before { get carts_path(locale: :en) }
        specify { expect(response).to redirect_to(root_path(locale: :en)) }
      end

      describe 'collect items for sales' do
        before { get item_collection_carts_path(locale: :en) }
        specify { expect(response).to redirect_to(root_path(locale: :en)) }
      end

      describe 'collect line items for redemption' do
        before { get line_item_collection_carts_path(locale: :en) }
        specify { expect(response).to redirect_to(root_path(locale: :en)) }
      end

    end

    describe 'in the counter controller' do

      describe 'visiting the counter index page' do
        before { get counter_index_path(locale: :en) }
        specify { expect(response).to redirect_to(root_path(locale: :en)) }
      end

    end

    describe 'in the sellings controller' do
      let(:event)         { FactoryGirl.create(:active) }
      let(:seller)        { FactoryGirl.create(:user) }
      let(:accepted_list) { FactoryGirl.create(:accepted, event: event, 
                                               user: seller) }
      let(:selling)       { create_selling_and_items(event, accepted_list) }

      describe 'visiting the sellings index page' do
        before { get sellings_path(locale: :en) }
        specify { expect(response).to redirect_to(root_path(locale: :en)) }
      end

      describe 'show selling' do
        before { get selling_path(selling, locale: :en) }
        specify { expect(response).to redirect_to(root_path(locale: :en)) }
      end

      describe 'check out selling' do
        before { get check_out_selling_path(selling, locale: :en) }
        specify { expect(response).to redirect_to(root_path(locale: :en)) }
      end

    end

    describe 'in the reversals controller' do
      let(:event)         { FactoryGirl.create(:active) }
      let(:seller)        { FactoryGirl.create(:user) }
      let(:accepted_list) { FactoryGirl.create(:accepted, event: event, 
                                               user:seller) }
      let(:selling)       { create_selling_and_items(event, accepted_list) }
      let(:reversal)      { create_reversal(event, selling, 0, 1) }


      describe 'visiting the reversals index page' do
        before { get reversals_path(locale: :en) }
        specify { expect(response).to redirect_to(root_path(locale: :en)) }
      end

      describe 'show reversal' do
        before { get reversal_path(reversal, locale: :en) }
        specify { expect(response).to redirect_to(root_path(locale: :en)) }
      end

      describe 'check_out_reversal' do
        before { get check_out_reversal_path(reversal, locale: :en) }
        specify { expect(response).to redirect_to(root_path(locale: :en)) }
      end

    end

  end

  describe 'as operator user' do
    let(:user) { FactoryGirl.create(:user) }
    let(:list) { FactoryGirl.create(:list, user: user) }

    let(:operator) { FactoryGirl.create(:operator) }

    before { sign_in operator }

    describe 'in the acceptances controller' do
      
      describe 'visiting the acceptances page' do
        before { visit acceptances_path(locale: :en) }
        it { expect(page.current_path).to eq acceptances_path(locale: :en) }
      end

      describe 'accept list' do
        before { post accept_acceptance_path(list, locale: :en) }
        specify { expect(response).to redirect_to(acceptances_path(locale: :en)) }
      end

      describe 'edit list' do
        it "number" do
          xhr :get,  edit_list_acceptance_path(list, locale: :en), format: :js 
          expect(page.status_code).to be(200)
        end
      end

    end

    describe 'in the carts controller' do

      describe 'visiting the carts page' do
        before { visit carts_path(locale: :en) }
        it { expect(page.current_path).to eq carts_path(locale: :en) }
      end

      describe 'collect items for sales' do
        before { visit item_collection_carts_path(locale: :en) }
        it { expect(page.current_path).to eq \
             item_collection_carts_path(locale: :en) }
      end

      describe 'collect line items for redemption' do
        before { visit line_item_collection_carts_path(locale: :en) }
        it { expect(page.current_path).to eq \
             line_item_collection_carts_path(locale: :en) }
      end

    end

    describe 'in the counter controller' do

      let!(:event) { FactoryGirl.create(:active) }

      describe 'visiting the counter index page' do
        before { visit counter_index_path(locale: :en) }
        it { expect(page.current_path).to eq counter_index_path(locale: :en) }
      end

    end

    describe 'in the sellings controller' do

      let(:event)         { FactoryGirl.create(:active) }
      let(:seller)        { FactoryGirl.create(:user) }
      let(:accepted_list) { FactoryGirl.create(:accepted, event: event, 
                                               user: seller) }
      let(:selling)       { create_selling_and_items(event, accepted_list) }

      describe 'visiting the sellings index page' do
        before { get sellings_path(locale: :en) }
        specify { expect(response).to redirect_to(root_path(locale: :en)) }
      end

      describe 'show selling' do
        before { visit selling_path(selling, locale: :en) }
        it { expect(page.current_path).to eq selling_path(selling, locale: :en) }
      end

      describe 'check out selling' do
        before { visit check_out_selling_path(selling, locale: :en) }
        it { expect(page.current_path).to eq check_out_selling_path(selling, 
                                                                locale: :en) }
      end

    end

    describe 'in the reversals controller' do

      let(:event)         { FactoryGirl.create(:active) }
      let(:seller)        { FactoryGirl.create(:user) }
      let(:accepted_list) { FactoryGirl.create(:accepted, event: event, 
                                               user:seller) }
      let(:selling)       { create_selling_and_items(event, accepted_list) }
      let(:reversal)      { create_reversal(event, selling, 0, 1) }

      describe 'visiting the reversals index page' do
        before { get reversals_path(locale: :en) }
        specify { expect(response).to redirect_to(root_path(locale: :en)) }
      end

      describe 'show reversal' do
        before { visit reversal_path(reversal, locale: :en) }
        it { expect(page.current_path).to eq reversal_path(reversal, locale: :en) }
      end

      describe 'check_out_reversal' do
        before { visit check_out_reversal_path(reversal, locale: :en) }
        it { expect(page.current_path).to eq check_out_reversal_path(reversal,
                                                                 locale: :en) }
      end

    end

  end

  describe 'as admin user' do
    let(:user) { FactoryGirl.create(:user) }
    let(:list) { FactoryGirl.create(:list, user: user) }

    let(:admin) { FactoryGirl.create(:admin) }

    before { sign_in admin }

    describe 'in the acceptances controller' do
      
      describe 'visiting the acceptances page' do
        before { visit acceptances_path(locale: :en) }
        it { expect(page.current_path).to eq acceptances_path(locale: :en) }
      end

      describe 'accept list' do
        before { post accept_acceptance_path(list, locale: :en) }
        specify { expect(response).to redirect_to(acceptances_path(locale: :en)) }
      end

      describe 'edit list' do
        it "number" do
          xhr :get,  edit_list_acceptance_path(list, locale: :en), format: :js 
          expect(page.status_code).to be(200)
        end
      end

    end

    describe 'in the carts controller' do

      describe 'visiting the carts page' do
        before { visit carts_path(locale: :en) }
        it { expect(page.current_path).to eq carts_path(locale: :en) }
      end

      describe 'collect items for sales' do
        before { visit item_collection_carts_path(locale: :en) }
        it { expect(page.current_path).to eq item_collection_carts_path(locale: :en) }
      end

      describe 'collect line items for redemption' do
        before { visit line_item_collection_carts_path(locale: :en) }
        it { expect(page.current_path).to eq line_item_collection_carts_path(locale: :en) }
      end

    end

    describe 'in the counter controller' do

      let!(:event) { FactoryGirl.create(:active) }

      describe 'visiting the counter index page' do
        before { visit counter_index_path(locale: :en) }
        it { expect(page.current_path).to eq counter_index_path(locale: :en) }
      end

    end

    describe 'in the sellings controller' do

      describe 'visiting the sellings index page' do
        before { visit sellings_path(locale: :en) }
        it { expect(page.current_path).to eq sellings_path(locale: :en) }
      end

    end

    describe 'in the reversals controller' do

      describe 'visiting the reversals index page' do
        before { visit reversals_path(locale: :en) }
        it { expect(page.current_path).to eq reversals_path(locale: :en) }
      end

    end

  end

end

