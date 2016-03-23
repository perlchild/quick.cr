module Quick
  MAX_SIZE = 100
  CHARS    = (0..127).map(&.chr).join.gsub(/[^[:print:]]/, "")
  RNG      = Random::DEFAULT

  FLOAT64_MIN_ORDER    = -324
  FLOAT64_MAX_ORDER    =  308
  FLOAT64_MIN_MANTISSA = -1.7
  FLOAT64_MAX_MANTISSA = -FLOAT64_MIN_MANTISSA
  FLOAT64_MIN          = -1.797e+308
  FLOAT64_MAX          = -FLOAT64_MIN

  FLOAT32_MIN_ORDER    =  -45
  FLOAT32_MAX_ORDER    =   38
  FLOAT32_MIN_MANTISSA = -1.7
  FLOAT32_MAX_MANTISSA = -FLOAT32_MIN_MANTISSA
  FLOAT32_MIN          = -1.797e+38
  FLOAT32_MAX          = -FLOAT32_MIN

  def min_for(t : RangedGenerator(T))
    t.lower_bound
  end

  def min_for(t : Float32.class)
    FLOAT32_MIN
  end

  def min_for(t : Float64.class)
    FLOAT64_MIN
  end

  def min_for(t : T.class)
    T::MIN
  end

  def max_for(t : RangedGenerator(T))
    t.upper_bound
  end

  def max_for(t : Float32.class)
    FLOAT32_MAX
  end

  def max_for(t : Float64.class)
    FLOAT64_MAX
  end

  def max_for(t : T.class)
    T::MAX
  end

  module Generator(T)
  end

  module RangedGenerator(T)
    abstract def lower_bound : T
    abstract def upper_bound : T
  end

  class RangeUtils(T)
    def self.min_size_of(n : T)
      n
    end

    def self.min_size_of(r : RangedGenerator(T))
      r.lower_bound
    end

    def self.max_size_of(n : T)
      n + 1
    end

    def self.max_size_of(r : RangedGenerator(T))
      r.upper_bound
    end
  end

  class GeneratorFor(T)
    def self.next_for(t : Bool.class)
      RNG.next_bool
    end

    def self.next_for(t : Char.class)
      _char
    end

    def self.next_for(t : Int32.class)
      _int
    end

    def self.next_for(t : UInt32.class)
      _int.to_u32
    end

    def self.next_for(t : Int8.class)
      _int.to_i8
    end

    def self.next_for(t : UInt8.class)
      _int.to_u8
    end

    def self.next_for(t : Int16.class)
      _int.to_i16
    end

    def self.next_for(t : UInt16.class)
      _int.to_u16
    end

    def self.next_for(t : Int64.class)
      _int64
    end

    def self.next_for(t : UInt64.class)
      _int64.to_u64
    end

    def self.next_for(t : Float64.class)
      _float64
    end

    def self.next_for(t : Float32.class)
      _float32
    end

    def self.next_for(t : ::String.class)
      ::String.build do |io|
        _array_like(io) { _char }
      end
    end

    def self.next_for(t : ::Array(U).class)
      _array_like([] of U) { GeneratorFor(U).next }
    end

    def self.next_for(t : {K, V}.class)
      {GeneratorFor(K).next, GeneratorFor(V).next}
    end

    def self.next_for(t : Hash(K, V).class)
      GeneratorFor(::Array({K, V})).next.to_h
    end

    def self.next_for(t : Generator(U).class)
      t
    end

    def self.next
      casted_value(next_for(T).not_nil!)
    end

    def self.casted_value(value : Generator(U).class)
      value.next as U
    end

    def self.casted_value(value)
      value as T
    end

    def self._int
      RNG.next_int
    end

    def self._int64
      # [-2^31, 2^31) * [-2^31, 2^31) * [0, 2] + [0, 1]
      # => [-2^63, 2^63)
      # and to increase uniq values:
      # + [-2^31, 2^31]
      _int.to_i64 * _int.to_i64 * rand(0..2) + rand(0..1) +
        _int.to_i64
    end

    def self._float64
      _float(
        FLOAT64_MIN_MANTISSA,
        FLOAT64_MAX_MANTISSA,
        FLOAT64_MIN_ORDER,
        FLOAT64_MAX_ORDER
      )
    end

    def self._float32
      _float(
        FLOAT32_MIN_MANTISSA,
        FLOAT32_MAX_MANTISSA,
        FLOAT32_MIN_ORDER,
        FLOAT32_MAX_ORDER
      ).to_f32
    end

    def self._float(min_mantissa, max_mantissa, min_order, max_order)
      RNG.rand(min_mantissa..max_mantissa) * 10 **
        RNG.rand(min_order..max_order)
    end

    def self._array_like(array, min_size = 0, max_size = MAX_SIZE)
      _size(min_size, max_size).times do
        array << yield
      end
      array
    end

    def self._size(min_size, max_size)
      RNG.rand(min_size...max_size)
    end

    def self._char
      CHARS[rand(CHARS.size)]
    end
  end

  macro def_literal(name, value)
    class {{name.id}}
      include Generator(typeof({{value}}))

      def self.next
        {{value}}
      end
    end
  end
end

require "./**"
