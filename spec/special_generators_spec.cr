require "./spec_helper"

Spec2.describe "Special generators" do
  include Quick
  include SpecHelpers

  macro describe_literal_generator(generator, value)
    describe "l : {{generator}}" do
      subject(generator) { GeneratorFor({{generator}}) }

      it "returns an Int32" do
        expect(generator.next).to be_a(typeof({{value}}))
        expect(typeof(generator.next)).to eq(typeof({{value}}))
      end

      it "always returns a specified literal value" do
        100.times do
          expect(generator.next).to eq({{value}})
        end
      end
    end
  end

  def_literal(AnswerOfTheUniverseGen, 42)
  describe_literal_generator(AnswerOfTheUniverseGen, value = 42)

  def_literal(HelloWorldGen, "hello world")
  describe_literal_generator(HelloWorldGen, value = "hello world")

  def_literal(SomeArrayGen, [1, 2, 4, 3])
  describe_literal_generator(SomeArrayGen, value = [1, 2, 4, 3])

  describe_integer_generator(
    Quick::Size,
    count = 100000,
    median = 50,
    median_precision = 2,
    uniq_count = MAX_SIZE,
    log10_count = 2,
    Int32
  )

  describe_integer_generator(
    Quick::Range(139, 792),
    count = 100000,
    median = 465,
    median_precision = 5,
    uniq_count = 600,
    log10_count = 1,
    Int32
  )

  describe_integer_generator(
    Quick::Range8(51, 125),
    count = 100000,
    median = 88,
    median_precision = 2,
    uniq_count = 70,
    log10_count = 2,
    Int8
  )

  describe_integer_generator(
    Quick::Range16(-19874, 352),
    count = 100000,
    median = -9761,
    median_precision = 100,
    uniq_count = 15000,
    log10_count = 4,
    Int16
  )

  describe_integer_generator(
    Quick::Range32(139, 792),
    count = 100000,
    median = 465,
    median_precision = 5,
    uniq_count = 600,
    log10_count = 1,
    Int32
  )

  describe_integer_generator(
    Quick::Range64(139, 792),
    count = 100000,
    median = 465,
    median_precision = 5,
    uniq_count = 600,
    log10_count = 1,
    Int64
  )

  describe_integer_generator(
    Quick::Range64(-3242342, 3242342),
    count = 100000,
    median = 0,
    median_precision = 20000,
    uniq_count = 90000,
    log10_count = 6,
    Int64
  )

  describe_float_generator(
    32,
    count = 100000,
    median = 39.75,
    median_precision = 2,
    uniq_count = 90000,
    log10_count = 1,
    FloatRange32(37, 42)
  )

  describe_float_generator(
    64,
    count = 100000,
    median = 176,
    median_precision = 5,
    uniq_count = 90000,
    log10_count = 1,
    FloatRange64(-77, 429)
  )

  describe_float_generator(
    64,
    count = 100000,
    median = 176,
    median_precision = 5,
    uniq_count = 90000,
    log10_count = 1,
    FloatRange(-77, 429)
  )

  describe_array_like(
    Array(Int32, 50),
    median_size = 50,
    median_precision = 0.1,
    min_size = 50,
    max_size = 50,
    unique_sized = 1,
    ::Array(Int32)
  )

  describe_array_like(
    Array(::String, 25),
    median_size = 25,
    median_precision = 0.1,
    min_size = 25,
    max_size = 25,
    unique_sized = 1,
    ::Array(::String)
  )

  describe_array_like(
    Array(Int32, Range(12, 25)),
    median_size = 18.5,
    median_precision = 2,
    min_size = 12,
    max_size = 24,
    unique_sized = 13,
    ::Array(Int32)
  )

  describe_array_like(
    String(25),
    median_size = 25,
    median_precision = 0.1,
    min_size = 25,
    max_size = 25,
    unique_sized = 1,
    ::String
  )

  describe_array_like(
    String(Range(10, 20)),
    median_size = 15,
    median_precision = 2,
    min_size = 10,
    max_size = 19,
    unique_sized = 10,
    ::String
  )

  describe "x : LiteralChoiceGen" do
    def_choice(ColorGen, "red", 35, "blue")
    subject(generator) { GeneratorFor(ColorGen) }

    it "returns value of union type" do
      expect(typeof(generator.next)).to eq(::String|Int32)
    end

    it "has correct distribution" do
      expected = {
        "red" => 33333,
        35 => 33333,
        "blue" => 33333
      }
      distribution(100000, generator, expected, 500, &.itself)
    end
  end

  describe "x : GenChoiceGen" do
    def_gen_choice(RangeChoiceGen, Range(0, 100), Range(50, 150), String(10))
    subject(generator) { GeneratorFor(RangeChoiceGen) }

    it "returns value of union type" do
      expect(typeof(generator.next)).to eq(::String|Int32)
    end

    it "has correct distribution by type" do
      expected = {
        Int32 => 66666,
        ::String => 33333
      }
      distribution(100000, generator, expected, 500, &.class)
    end
  end
end
