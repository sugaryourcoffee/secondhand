require 'spec_helper'

describe "event pages" do
  subject { page }

  describe "index" do
    let(:event) { FactoryGirl.create(:event) }
    let(:event_other) { FactoryGirl.create(:event) }
 
    describe "with user not signed in" do
      before { visit events_path(locale: :en) }

      it { should_not have_title("All events") }
      it { should_not have_selector('h1', text: "All events") }
    end

    describe "with non-admin user signed in" do
      let(:user) { FactoryGirl.create(:user) }

      before do
        sign_in(user)
        visit events_path(locale: :en)
      end

      it { should_not have_title("All events") }
      it { should_not have_selector('h1', text: "All events") }
    end

    describe "with admin user signed in" do
      let(:admin) { FactoryGirl.create(:admin) }

      before { sign_in(admin) }

      before(:each) { visit events_path(locale: :en) }
      before(:all) { 31.times { FactoryGirl.create(:event) } }
      after(:all) { Event.delete_all }

      it { should have_title("All events") }
      it { should have_selector('h1', text: "All events") }
      it { should have_link('New Event', href: new_event_path(locale: :en)) }

      it "should list each event" do
        Event.paginate(page: 1).each do |event|
          page.should have_selector('tr', text: event.title)
          page.should have_link('Show', href: event_path(event, locale: :en))
          page.should have_link('Edit', href: edit_event_path(event, locale: :en))
          page.should have_link('Destroy', href: event_path(event, locale: :en))
        end
      end

      describe "activate button" do
        before { visit events_path(locale: :en) }
        
        it { should_not have_button('Deactivate') }
        it { should have_button('Activate') }

        describe "click activate button" do
          before { first(:button, 'Activate').click }

          it { should have_button('Deactivate') }
        end
        
      end

      describe "delete button" do
        let!(:list) { FactoryGirl.create(:list, 
                                        list_number: 10, 
                                        registration_code: "acgd/e.", 
                                        event: event) } 

        let!(:assigned_list) { FactoryGirl.create(:assigned,
                                                  list_number: 11,
                                                  registration_code: "kdke..",
                                                  event: event_other) }
        before { visit events_path(locale: :en) }

        it "should delete event" do
          expect { first(:link, 'Destroy').click }.
            to change(Event, :count).by(-1)
        end

        it "should delete lists along with the event" do
#          event.lists.should have_exactly(1).items
          event.lists.size.should eq(1)
          
#          List.all.should have(2).items
          List.all.size.should eq(2)

          expect { event.destroy }.to change(Event, :count).by(-1)
          expect { Event.find(event) }.to raise_error #(ActiveRecord::RecordNotFound)
          
#          List.all.should have(1).items
          List.all.size.should eq(1)
        end

        it "should not delete active event" do
          should_not have_button('Deactivate')
          first(:button, 'Activate').click
          should have_button('Deactivate') 

          expect { first(:link, 'Destroy').click }.
            to change(Event, :count).by(0)

          should have_text('Cannot delete active event')
        end

        it "should not delete event with list register by a user" do
          event_other.lists.size.should eq(1)

          List.all.size.should eq(2)

          expect { event_other.destroy }
                 .to raise_error(ActiveRecord::RecordNotDestroyed)
          expect { event_other.save }.not_to raise_error

          List.all.size.should eq(2)
        end

      end

    end

  end

  describe "show page" do

    it "should show message when no items in list" do
    end

    it "should show items count and close list button" do
    end

  end

  describe "new event page" do
    let(:admin) { FactoryGirl.create(:admin) }

    before do
      sign_in(admin) 
      visit new_event_path
    end

    it "should create new event" do
      fill_in "Title", with: "a title"
      select Date.current.year, from: "event_event_date_1i"
      select 'December', from: "event_event_date_2i"
      select '17', from: "event_event_date_3i"
      fill_in "Location", with: "town"
      fill_in "Fee", with: "3"
      fill_in "Deduction", with: "20"
      fill_in "Provision", with: "15"
      fill_in "Maximum count of lists", with: "300"
      fill_in "Maximum items count per list", with: "40"
      select Date.current.year, from: "event_list_closing_date_1i"
      select 'March', from: "event_list_closing_date_2i"
      select '18', from: "event_list_closing_date_3i"
      fill_in "Delivery Location", with: "Back door of school"
      select Date.current.year, from: "event_delivery_date_1i"
      select 'March', from: "event_delivery_date_2i"
      select '20', from: "event_delivery_date_3i"
      select '12', from: "event_delivery_start_time_4i"
      select '30', from: "event_delivery_start_time_5i"
      select '14', from: "event_delivery_end_time_4i"
      select '30', from: "event_delivery_end_time_5i"
      fill_in "Collection Location", with: "Front door of school"
      select Date.current.year, from: "event_collection_date_1i"
      select 'March', from: "event_collection_date_2i"
      select '21', from: "event_collection_date_3i"
      select '14', from: "event_collection_start_time_4i"
      select '30', from: "event_collection_start_time_5i"
      select '15', from: "event_collection_end_time_4i"
      select '30', from: "event_collection_end_time_5i"
      fill_in "Information", with: "Next event 19.09.2015 | Newsletter"
      expect { click_button "Create Event" }.to change(Event, :count).by(1)
    end
  end
end
