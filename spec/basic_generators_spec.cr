require "./spec_helper"

Spec2.describe "Basic generators" do
  include Quick
  include SpecHelpers

  describe_integer_generator(
    Int32,
    count = 100000,
    median = 0,
    median_precision = 1e+7,
    uniq_count = 99000,
    log10_count = 5
  )

  describe_integer_generator(
    UInt32,
    count = 100000,
    median = Int32::MAX.to_u32,
    median_precision = 1e+7,
    uniq_count = 99000,
    log10_count = 5
  )

  describe_integer_generator(
    Int8,
    count = 10000,
    median = 0,
    median_precision = 10,
    uniq_count = 250,
    log10_count = 3
  )

  describe_integer_generator(
    UInt8,
    count = 10000,
    median = Int8::MAX.to_u8,
    median_precision = 10,
    uniq_count = 250,
    log10_count = 3
  )

  describe_integer_generator(
    Int16,
    count = 100000,
    median = 0,
    median_precision = 1000,
    uniq_count = 45000,
    log10_count = 4
  )

  describe_integer_generator(
    UInt16,
    count = 100000,
    median = Int16::MAX.to_u16,
    median_precision = 1000,
    uniq_count = 45000,
    log10_count = 4
  )

  describe_integer_generator(
    Int64,
    count = 100000,
    median = 0,
    median_precision = 1e+17,
    uniq_count = 99000,
    log10_count = 12
  )

  describe_integer_generator(
    UInt64,
    count = 100000,
    median = Int64::MAX.to_u64,
    median_precision = 1e+17,
    uniq_count = 99000,
    log10_count = 12
  )

  describe_float_generator(
    64,
    count = 100000,
    median = 0,
    median_precision = 1e305,
    uniq_count = 90000,
    log10_count = 600
  )

  describe_float_generator(
    32,
    count = 100000,
    median = 0,
    median_precision = 1e305,
    uniq_count = 90000,
    log10_count = 80
  )

  macro describe_array_like(ty, median_size = 50, median_precision = 5, min_size = 0, max_size = Quick::MAX_SIZE, unique_sized = 99)
    describe "s : {{ty}}" do
      subject(generator) { GeneratorFor({{ty}}) }

      it "returns a {{ty}}" do
        expect(generator.next).to be_a({{ty}})
        expect(typeof(generator.next)).to eq({{ty}})
      end

      it "has proper median" do
        median(1000, generator, {{median_size}}, {{median_precision}}, &.size)
      end

      it "has proper min variance" do
        variance(1000, generator, {{median_size}}, {{min_size}}, 0.9, 1, &.size)
      end

      it "has proper max variance" do
        variance(1000, generator, {{median_size}}, {{max_size}}, 0.9, 1, &.size)
      end

      it "generates enough unique sized arrays" do
        enough_uniqueness(1000, generator, {{unique_sized}}, &.size)
      end

      it "generates enough unique valued values" do
        enough_uniqueness(1000, generator, 900, &.itself)
      end
    end
  end

  describe_array_like(String)

  describe_array_like(Array(UInt32))
  describe_array_like(Array(Int32))

  describe_array_like(Array(UInt8))
  describe_array_like(Array(Int8))

  describe_array_like(Array(UInt16))
  describe_array_like(Array(Int16))

  describe_array_like(Array(UInt64))
  describe_array_like(Array(Int64))

  describe_array_like(Array(Float32))
  describe_array_like(Array(Float64))

  describe_array_like(Array(String))
  describe_array_like(Array(Bool))

  describe_array_like(Array(Array(Int32)))

  describe_array_like(
    Tuple(Int32, String),
    median_size = 2,
    median_precision = 0.1,
    min_size = 2,
    max_size = 2,
    unique_sized = 1
  )

  describe_array_like(Hash(String, Float64))

  describe "b : Bool" do
    subject(generator) { GeneratorFor(Bool) }

    it "returns a Bool" do
      expect(generator.next).to be_a(Bool)
      expect(typeof(generator.next)).to eq(Bool)
    end

    it "has good distribution" do
      expected = {
        true => 50000,
        false => 50000
      }

      distribution(100000, generator, expected, 1000, &.itself)
    end

    it "doesn't have very long streaks" do
      streaks(100000, generator, 30, &.itself)
    end
  end
end
