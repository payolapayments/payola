require 'spec_helper'

module Payola
  describe Sellable do
    describe "validations" do
      it "should validate" do
        product = build(:product)
        expect(product.valid?).to be true
      end
      it "should validate name" do
        product = build(:product, name: nil)
        expect(product.valid?).to be false
      end
      it "should validate permalink" do
        product = build(:product, permalink: nil)
        expect(product.valid?).to be false
      end
    end

    describe "#product_class" do
      it "should return the underscore'd version of the class" do
        expect(build(:product).product_class).to eq 'product'
      end
    end

    describe "#sellable?" do
      it "should return true" do
        expect(Product.sellable?).to be true
      end
    end
  end
end
