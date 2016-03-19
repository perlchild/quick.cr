require "./spec_helper"

Spec2.describe Quick do
  include Quick

  describe "x : Int32" do
    subject(generator) { GeneratorFor(Int32) }

    it "returns an Int32" do
      expect(generator.next).to be_a(Int32)
      expect(typeof(generator.next)).to eq(Int32)
    end

    it "has proper median" do
      median(100000, generator, 0, 30000, &.itself)
    end

    it "has proper variance" do
      variance(100000, generator, 0, Int32::MIN - 1, 0.9, 1, &.itself)
      variance(100000, generator, 0, Int32::MAX + 1, 0.9, 1, &.itself)
    end

    it "generates enough unique values" do
      enough_uniqueness(100000, generator, 99000, &.itself)
    end
  end

  describe "s : String" do
    subject(generator) { GeneratorFor(String) }

    it "returns a String" do
      expect(generator.next).to be_a(String)
      expect(typeof(generator.next)).to eq(String)
    end

    it "has proper median" do
      median(1000, generator, 50, 5, &.size)
    end

    it "has proper min variance" do
      variance(1000, generator, 50, 0, 0.9, 1, &.size)
    end

    it "has proper max variance" do
      variance(1000, generator, 50, Quick::MAX_SIZE, 0.9, 1, &.size)
    end

    it "generates enough unique sized strings" do
      enough_uniqueness(1000, generator, 99, &.size)
    end

    it "generates enough unique valued strings" do
      enough_uniqueness(1000, generator, 900, &.itself)
    end
  end

  def median(count, generator, expected, difference)
    values = (0..count).map { yield(generator.next) }
    actual = values.sum / values.size
    expect(actual).to be_close(expected, difference)
  end

  def variance(count, generator, median, extreme, threshold, expected)
    values = (0..count).map { yield(generator.next) }

    extreme_count = values
      .map(&.to_f.-(extreme)./(extreme - median).+(1))
      .count(&.>=(threshold))
    expect(extreme_count).to_be >= expected
  end

  def enough_uniqueness(count, generator, expected)
    values = (0..count).map { yield(generator.next) }
    expect(values.uniq.size).to_be >= expected
  end
end
