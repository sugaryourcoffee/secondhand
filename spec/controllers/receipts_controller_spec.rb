# frozen_string_literal: true

require 'spec_helper'

describe ReceiptsController do
  if version_incompatibility
    puts 'skip test because of incomaptibility of Ruby 2.6 and Rails 4.2'
  else
    puts "remove if clause in '#{__FILE__}"
    describe 'GET index' do
      it 'returns http success' do
        get :show
        expect(response).to be_success
      end
    end
    describe 'GET show' do
      it 'returns http success' do
        get :show
        expect(response).to be_success
      end
    end
    describe 'GET print' do
      it 'returns http success' do
        get :print
        expect(response).to be_success
      end
    end
    describe 'GET dwonload' do
      it 'returns http success' do
        get :download
        expect(response).to be_success
      end
    end
  end
end
