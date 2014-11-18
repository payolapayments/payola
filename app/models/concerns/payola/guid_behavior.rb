require 'active_support/concern'

module Payola
  module GuidBehavior
    extend ActiveSupport::Concern
    
    included do
      before_save :populate_guid
      validates_uniqueness_of :guid
    end

    def populate_guid
      if new_record?
        while !valid? || self.guid.nil?
          self.guid = SecureRandom.random_number(1_000_000_000).to_s(32)
        end
      end
    end
  end
end
