require "./quick/*"

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

  class GeneratorFor(T)
    def self.next?
      case
      when T == Int32
        _int
      when T == UInt32
        _int.to_u32
      when T == Int8
        _int.to_i8
      when T == UInt8
        _int.to_u8
      when T == UInt16
        _int.to_u16
      when T == Int64
        _int64
      when T == UInt64
        _int64.to_u64
      when T == Float64
        _float64
      when T == Float32
        _float32
      when T == String
        String.build do |io|
          _array_like(io) { _char }
        end
      when T == Bool
        RNG.next_bool
      else
        t = uninitialized T
        _array_like_for(t)
      end
    end

    def self.next
      next?.not_nil! as T
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

    def self._array_like(array)
      _size.times do
        array << yield
      end
      array
    end

    def self._size
      rand(MAX_SIZE)
    end

    def self._char
      CHARS[rand(CHARS.size)]
    end

    def self._array_like_for(t : Enumerable(U))
      _array_like([] of U) { GeneratorFor(U).next }
    end

    def self._array_like_for(t)
    end
  end
end
