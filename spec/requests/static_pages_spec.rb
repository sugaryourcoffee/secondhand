require 'spec_helper'

describe "Static pages" do

  let(:base_title) { "Secondhand" }

  describe "Home page" do
    it "should have the h1 'Secondhand'" do
      visit root_path
      page.should have_selector('h1', :text => 'Secondhand')
    end

    it "should have the title 'Home'" do
      visit root_path
      page.should have_title("#{base_title} | Home")
    end
  end

  describe "Help page" do
    it "should have the h1 'Help'" do
      visit help_path
      page.should have_selector('h1', :text => 'Help')
    end

    it "should have the title 'Help'" do
      visit help_path
      page.should have_title("#{base_title} | Help")
    end
  end

  describe "About page" do
    it "should have the h1 'About Us'" do
      visit about_path
      page.should have_selector('h1', :text => 'About Us')
    end

    it "should have the title 'About Us'" do
      visit about_path
      page.should have_title("#{base_title} | About Us")
    end
  end

  describe "Contact page" do
    it "should have the h1 'Contact'" do
      visit contact_path
      page.should have_selector('h1', :text => 'Contact')
    end

    it "should have the title 'Contact'" do
      visit contact_path
      page.should have_title("#{base_title} | Contact")
    end
  end
end
