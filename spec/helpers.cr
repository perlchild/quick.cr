module SpecHelpers
  macro describe_integer_generator(gen_ty, count, median, median_precision, uniq_count, log10_count, expected_type = __NOP__)
    {% expected_type = gen_ty if expected_type.stringify == "__NOP__" %}

    describe "x : {{gen_ty}}" do
      subject(generator) { GeneratorFor({{gen_ty}}) }

      it "returns an {{gen_ty}}" do
        expect(generator.next).to be_a({{expected_type}})
        expect(typeof(generator.next)).to eq({{expected_type}})
      end

      it "has proper median" do
        median({{count}}, generator, {{median}}, {{median_precision}}, &.itself)
      end

      it "has proper min=#{min_for({{gen_ty}})} variance" do
        variance({{count}}, generator, 0, min_for({{gen_ty}}), 0.9, 1, &.itself)
      end

      it "has proper max=#{max_for({{gen_ty}})} variance" do
        variance({{count}}, generator, 0, max_for({{gen_ty}}), 0.9, 1, &.itself)
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

  macro describe_float_generator(bits, count, median, median_precision, uniq_count, log10_count, gen_ty = nil)
    {% ty = "Float#{bits}".id %}
    {% gen_ty = ty unless gen_ty %}

    describe "f : {{gen_ty}}" do
      subject(generator) { GeneratorFor({{gen_ty}}) }

      it "returns a {{ty}}" do
        expect(generator.next).to be_a({{ty}})
        expect(typeof(generator.next)).to eq({{ty}})
      end

      it "has proper median" do
        median({{count}}, generator, {{median}}, {{median_precision}}, &.itself)
      end

      it "has proper min=#{min_for({{gen_ty}})} variance" do
        variance({{count}}, generator, 0, min_for({{gen_ty}}), 0.9, 1, &.itself)
      end

      it "has proper max=#{max_for({{gen_ty}})} variance" do
        variance({{count}}, generator, 0, max_for({{gen_ty}}), 0.9, 1, &.itself)
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

  macro describe_array_like(ty, median_size = 50, median_precision = 5, min_size = 0, max_size = Quick::MAX_SIZE, unique_sized = 99, expected_type = nil)
    {% expected_type = ty unless expected_type %}

    describe "s : {{ty}}" do
      subject(generator) { GeneratorFor({{ty}}) }

      it "returns a {{ty}}" do
        expect(generator.next).to be_a({{expected_type}})
        expect(typeof(generator.next)).to eq({{expected_type}})
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

  def median(count, generator, expected, difference)
    values = (0...count).map { yield(generator.next) }
    actual = values.map(&.to_f./(count)).sum
    expect(actual).to be_close(expected, difference)
  end

  def variance(count, generator, median, extreme, threshold, expected)
    return if median == extreme

    values = (0...count).map { yield(generator.next) }

    extreme_count = values
      .map(&.to_f.-(extreme)./(extreme - median).+(1))
      .count(&.>=(threshold))
    expect(extreme_count).to_be >= expected
  end

  def enough_uniqueness(count, generator, expected)
    values = (0...count).map { yield(generator.next) }
    expect(values.uniq.size).to_be >= expected
  end

  def distribution(count, generator, expected_counts, difference)
    values = (0...count).map { yield(generator.next) }
    expected_counts.each do |value, expected|
      expect(values.count { |x| value == x })
        .to be_close(expected, difference)
    end
  end

  def streaks(count, generator, max_streak)
    largest = 0
    streak = 1
    previous = yield(generator.next)
    (0...count).each do
      value = yield(generator.next)

      if value == previous
        streak += 1
        largest = [streak, largest].max
      else
        previous = value
        streak = 1
      end
    end

    expect(largest).to_be < max_streak
  end

  class Caught(T)
    def initialize(@error : ::Quick::CheckFailedError(T)?)
    end

    def when_caught
      if error = @error
        return yield(error.failed_args)
      end

      true
    end
  end

  macro caught(args, &block)
    {% vars = args.map(&.var) %}
    {% types = args.map(&.type) %}
    {% types_tuple = "{#{types.argify}}".id %}
    {% gens = types.map { |t| "::Quick::GeneratorFor(#{t})".id } %}
    {% gens_tuple = "{#{gens.argify}}".id %}
    {% value_types = gens.map { |g| "typeof(#{g}.next)".id } %}
    {% value_types_tuple = "{#{value_types.argify}}".id %}

    begin
      Quick.check("a property", {{args}}) {{block}}
      Caught({{value_types_tuple}}).new(nil)
    rescue error : Quick::CheckFailedError({{value_types_tuple}})
      Caught.new(error)
    end
  end
end
