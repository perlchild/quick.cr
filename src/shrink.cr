module Quick
  module Shrinker(T)
  end

  # G - Generator(T)
  class ShrinkerFor(G, T)
    ARRAY_SHRINKER_PASSES = 5
    INTEGER_SHRINKER_MAX_SHRINKS = 1000

    def self.shrink(failed_value : T, &prop : T -> Bool)
      shrink_for(G, failed_value, prop)
    end

    def self.shrink_for(g : Shrinker(U).class, failed_value, prop)
      g.shrink(failed_value, prop)
    end

    def self.shrink_for(g : Int.class, failed_value, prop)
      return integer_value_for(T, 0) if failed_value == 0
      original_sign = sign(failed_value)

      shrinks_left = INTEGER_SHRINKER_MAX_SHRINKS
      shrink_step = integer_value_for(T, 1)
      previous_value = failed_value

      while shrink_step > 0 && shrinks_left > 0
        previous_value = failed_value
        failed_value -= shrink_step * original_sign
        shrinks_left -= 1

        if ![original_sign, 0].includes?(sign(failed_value)) ||
           prop.call(failed_value)
          failed_value = previous_value
          shrink_step /= 2
        else
          shrink_step *= 2
        end
      end

      integer_value_for(T, failed_value)
    end

    def self.shrink_for(g : ::Array(U).class, failed_value, prop)
      left = [] of U
      right = failed_value.dup

      while !right.empty?
        head = right.shift
        if prop.call(left + right)
          left << ShrinkerFor(U, U).shrink(head) do |value|
            prop.call(left + [value] + right)
          end
        end
      end

      ARRAY_SHRINKER_PASSES.times do
        left.each_with_index do |value, index|
          left[index] = ShrinkerFor(U, U).shrink(value) do |next_value|
            left[index] = next_value
            prop.call(left).tap do
              left[index] = value
            end
          end
        end
      end

      left
    end

    def self.shrink_for(g : ::String.class, failed_value, prop)
      ShrinkerFor(::Array(Char), ::Array(Char)).shrink(failed_value.chars) do |value|
        prop.call(value.join)
      end.join
    end

    def self.shrink_for(g : {A, B}.class, failed_value : {K, V}, prop)
      first = ShrinkerFor(K, K).shrink(failed_value[0]) do |value|
        prop.call({value, failed_value[1]})
      end

      second = ShrinkerFor(V, V).shrink(failed_value[1]) do |value|
        prop.call({first, value})
      end

      {first, second}
    end

    def self.shrink_for(g : Float.class, failed_value, prop)
      Unsafe.itof(
        ShrinkerFor(typeof(Unsafe.ftoi(failed_value)), typeof(Unsafe.ftoi(failed_value)))
        .shrink(Unsafe.ftoi(failed_value)) do |value|
          prop.call(Unsafe.itof(value))
        end
      )
    end

    def self.shrink_for(g : Hash(A, B).class, failed_value : Hash(K, V), prop)
      ShrinkerFor(::Array({K, V}), ::Array({K, V}))
      .shrink(failed_value.to_a) do |value|
        prop.call(value.to_h)
      end.to_h
    end

    def self.shrink_for(g : GeneratorFor(U).class, failed_value, prop)
      ShrinkerFor(U, T).shrink(failed_value, &prop)
    end

    def self.shrink_for(g, failed_value, prop)
      failed_value
    end

    def self.sign(value)
      return -1 if value < 0
      return 1 if value > 0
      0
    end

    macro def_integer_value_for(bits, signedness)
      {% prefix = signedness.id.stringify == "u" ? "U".id : "".id %}

      def self.integer_value_for(t : {{prefix}}Int{{bits}}.class, x : Int)
        x.to_{{signedness}}{{bits}}
      end
    end

    macro def_integer_value_for(bits)
      def_integer_value_for({{bits}}, i)
      def_integer_value_for({{bits}}, u)
    end

    def_integer_value_for(8)
    def_integer_value_for(16)
    def_integer_value_for(32)
    def_integer_value_for(64)
  end
end
