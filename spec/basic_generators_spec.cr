require "./spec_helper"

Spec2.describe "Basic generators" do
  include Quick

  macro describe_integer_generator(ty, count, median, median_precision, uniq_count, log10_count)
    describe "x : {{ty}}" do
      subject(generator) { GeneratorFor({{ty}}) }

      it "returns an {{ty}}" do
        expect(generator.next).to be_a({{ty}})
        expect(typeof(generator.next)).to eq({{ty}})
      end

      it "has proper median" do
        median({{count}}, generator, {{median}}, {{median_precision}}, &.itself)
      end

      it "has proper min variance" do
        variance({{count}}, generator, 0, {{ty}}::MIN, 0.9, 1, &.itself)
      end

      it "has proper max variance" do
        variance({{count}}, generator, 0, {{ty}}::MAX, 0.9, 1, &.itself)
      end

      it "generates enough unique values" do
        enough_uniqueness({{count}}, generator, {{uniq_count}}, &.itself)
      end

      it "generates enough unique log10 values" do
        enough_uniqueness({{count}}, generator, {{log10_count}}) do |x|
          Math.log10(x).to_i
        end
      end
    end
  end

  describe_integer_generator(
    Int32,
    count=100000,
    median=0,
    median_precision=1e+7,
    uniq_count=99000,
    log10_count=5
  )

  describe_integer_generator(
    UInt32,
    count=100000,
    median=Int32::MAX.to_u32,
    median_precision=1e+7,
    uniq_count=99000,
    log10_count=5
  )

  describe_integer_generator(
    Int8,
    count=10000,
    median=0,
    median_precision=10,
    uniq_count=250,
    log10_count=3
  )

  describe_integer_generator(
    UInt8,
    count=10000,
    median=Int8::MAX.to_u8,
    median_precision=10,
    uniq_count=250,
    log10_count=3
  )

  describe_integer_generator(
    UInt16,
    count=100000,
    median=Int16::MAX.to_u16,
    median_precision=1000,
    uniq_count=45000,
    log10_count=4
  )

  describe_integer_generator(
    Int64,
    count=100000,
    median=0,
    median_precision=1e+17,
    uniq_count=99000,
    log10_count=12
  )

  describe_integer_generator(
    UInt64,
    count=100000,
    median=Int64::MAX.to_u64,
    median_precision=1e+17,
    uniq_count=99000,
    log10_count=12
  )

  # FIXME: https://github.com/crystal-lang/crystal/issues/2321
  #describe_integer_generator(Int16, ...)

  macro describe_float_generator(bits, count, median, median_precision, uniq_count, log10_count)
    {% ty = "Float#{bits}".id %}
    {% cty = "FLOAT#{bits}".id %}

    describe "f : {{ty}}" do
      subject(generator) { GeneratorFor({{ty}}) }

      it "returns a {{ty}}" do
        expect(generator.next).to be_a({{ty}})
        expect(typeof(generator.next)).to eq({{ty}})
      end

      it "has proper median" do
        median({{count}}, generator, {{median}}, {{median_precision}}, &.itself)
      end

      it "has proper min variance" do
        variance({{count}}, generator, 0, {{"#{cty}_MIN".id}}, 0.9, 1, &.itself)
      end

      it "has proper max variance" do
        variance({{count}}, generator, 0, {{"#{cty}_MAX".id}}, 0.9, 1, &.itself)
      end

      it "generates enough unique values" do
        enough_uniqueness({{count}}, generator, {{uniq_count}}, &.itself)
      end

      it "generates enough unique log10 values" do
        enough_uniqueness({{count}}, generator, {{log10_count}}) do |x|
          Math.log10(x).to_i
        end
      end
    end
  end

  describe_float_generator(
    64,
    count=100000,
    median=0,
    median_precision=1e305,
    uniq_count=90000,
    log10_count=600
  )

  describe_float_generator(
    32,
    count=100000,
    median=0,
    median_precision=1e305,
    uniq_count=90000,
    log10_count=80
  )

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
    actual = values.map(&.to_f./(count)).sum
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
