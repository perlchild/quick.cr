require "./quick/*"

module Quick
  MAX_SIZE = 100
  CHARS = (0..127).map(&.chr).join.gsub(/[^[:print:]]/, "")
  RNG = Random::DEFAULT

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

      when T == String
        String.build do |io|
          size = rand(MAX_SIZE)
          size.times do
            io << CHARS[rand(CHARS.size)]
          end
        end

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
      _int.to_i64 * _int.to_i64 * rand(0...3) + rand(0...1) +
        _int.to_i64
    end
  end
end
