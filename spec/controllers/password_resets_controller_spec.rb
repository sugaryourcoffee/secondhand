# frozen_string_literal: true

require 'spec_helper'

describe PasswordResetsController do
  describe "GET 'new'" do
    it 'returns http success' do
      if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new('2.6') &&
         Gem::Version.new(Rails.version) < Gem::Version.new('5')
        puts 'skip test because of incomaptibility of Ruby 2.6 and Rails 4.2'
      else
        puts "remove if in '#{__FILE__}"
        get 'new'
        expect(response).to be_success
      end
    end
  end
end
