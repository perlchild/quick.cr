module Quick
  module Unsafe
    extend self

    macro def_conversion(name, from, to)
      def {{name.id}}(x : {{from}})
        (pointerof(x) as Pointer({{to}})).value
      end
    end

    def_conversion itof, Int32, Float32
    def_conversion itof, Int64, Float64
    
    def_conversion ftoi, Float32, Int32
    def_conversion ftoi, Float64, Int64
  end
end
