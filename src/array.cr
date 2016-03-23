module Quick
  class Array(T, N)
    include Generator(::Array(T))

    def self.next
      GeneratorFor._array_like(
        [] of T,
        min_size: RangeUtils(Int32).min_size_of(N),
        max_size: RangeUtils(Int32).max_size_of(N)
      ) { GeneratorFor(T).next }
    end
  end

  class String(N)
    include Generator(::String)

    def self.next
      ::String.build do |io|
        GeneratorFor._array_like(
          io,
          min_size: RangeUtils(Int32).min_size_of(N),
          max_size: RangeUtils(Int32).max_size_of(N)
        ) { GeneratorFor(Char).next }
      end
    end
  end
end
