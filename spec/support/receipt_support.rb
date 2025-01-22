# frozen_string_literal: true

def version_incompatibility
  Gem::Version.new(RUBY_VERSION) >= Gem::Version.new('2.6') &&
    Gem::Version.new(Rails.version) < Gem::Version.new('5')
end
