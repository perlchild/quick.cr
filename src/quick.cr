require "./quick/*"

module Quick
  MAX_SIZE = 100
  CHARS = (0..127).map(&.chr).join.gsub(/[^[:print:]]/, "")

  class GeneratorFor(T)
    def self.next?
      case

      when T == Int32
        Random::DEFAULT.next_int

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
  end
end
