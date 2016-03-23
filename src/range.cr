module Quick
  macro def_range(name, ty, &to_range_length)
    class {{name.id}}(A, B)
      extend Generator({{ty.id}})
      extend RangedGenerator({{ty.id}})

      def self.next
        transposed_value
      end

      def self.lower_bound
        {{ty}}.new(A)
      end

      def self.upper_bound
        {{ty}}.new(B)
      end

      def self.range_length
        upper_bound - lower_bound
      end

      def self.value_of_range_length
        {{to_range_length.body}}
      end

      def self.transposed_value
        value_of_range_length + lower_bound
      end
    end
  end

  macro def_int_range(bits)
    def_range(Range{{bits.id}}, Int{{bits.id}}) do
      GeneratorFor(Int{{bits.id}}).next % range_length
    end
  end

  macro def_float_range(bits)
    def_range(FloatRange{{bits.id}}, Float{{bits.id}}) do
      RNG.rand.to_f{{bits.id}} * range_length
    end
  end

  def_int_range(8)
  def_int_range(16)
  def_int_range(32)
  def_int_range(64)
  alias Range = Range32

  def_float_range(32)
  def_float_range(64)
  alias FloatRange = FloatRange64
end
