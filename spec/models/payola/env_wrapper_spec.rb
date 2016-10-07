require 'spec_helper'

module Payola
  describe EnvWrapper do
    describe "delegations" do
      it "should delgate is_a?" do
        ENV['whatever'] = 'some value'
        wrap = EnvWrapper.new('whatever')
        expect(wrap.is_a?(String)).to be_truthy
      end
    end
  end
end
