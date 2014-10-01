require 'spec_helper'

module Payola
  describe Sellable do
    describe "validations" do
      it "should validate name"
      it "should validate permalink"
    end

    describe "#product_class" do
      it "should return the underscore'd version of the class"
    end

    describe "#sellable?" do
      it "should return true"
    end
  end
end
