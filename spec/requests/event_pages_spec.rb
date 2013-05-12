require 'spec_helper'

describe "event pages" do
  subject { page }

  describe "index" do
    let(:event) { FactoryGirl.create(:event) }
 
    before(:each) { visit events_path }
    before(:all) { 31.times { FactoryGirl.create(:event) } }
    after(:all) { Event.delete_all }

    it { should have_title("All events") }
    it { should have_selector('h1', text: "All events") }
    it { should have_link('New Event', href: new_event_path) }

    it "should list each event" do
      Event.paginate(page: 1).each do |event|
        page.should have_selector('tr', text: event.title)
        page.should have_link('Show', href: event_path(event))
        page.should have_link('Edit', href: edit_event_path(event))
        page.should have_link('Destroy', href: event_path(event))
      end
    end

    describe "activate button" do
      before { visit events_path }
      
      it { should_not have_button('Deactivate') }
      it { should have_button('Activate') }

      describe "click activate button" do
        before { first(:button, 'Activate').click }

        it { should have_button('Deactivate') }
      end
      
    end

  end
end
