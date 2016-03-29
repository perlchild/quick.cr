module Quick
  class CheckFailedError(T) < Exception
    getter property_name, failed_args
    def initialize(@property_name, @failed_args : T = nil)
      super(nil, nil)
    end

    def message
      "Property '#{property_name}' failed\n\twith arguments: #{failed_args.inspect}"
    end
  end

  DEFAULT_TEST_COUNT = 100

  class SimpleCheck
    def initialize(@name)
    end

    def check(number_of_tests)
      number_of_tests.times do
        result = yield

        unless result
          raise CheckFailedError.new(@name)
        end
      end
    end
  end

  class Check(T)
    def initialize(@name, &@gen_to_value : Proc(T))
    end

    def with_shrink_strategy(&@shrinking_strategy : Proc(T, Proc(T, Bool), T))
      self
    end

    def next_values
      @gen_to_value.call
    end

    def shrink(values, prop : T -> Bool)
      if strategy = @shrinking_strategy
        return strategy.call(values, prop)
      end
      values
    end

    def check(number_of_tests, &prop : Proc(T, Bool))
      number_of_tests.times do
        values = next_values
        result = prop.call(values)

        unless result
          raise CheckFailedError.new(@name, shrink(values, prop))
        end
      end
    end
  end

  macro _tuple_assoc(tuple, size, idx, value)
    {
      {% for i in (0...size) %}
        {% if i == idx %} {{value}} {% else %} {{tuple}}[{{i}}] {% end %},
      {% end %}
    }
  end

  macro check(name, args = nil, number_of_tests = ::Quick::DEFAULT_TEST_COUNT, &block)
    {% if args %}

      {% vars = args.map(&.var) %}
      {% types = args.map(&.type) %}
      {% types_tuple = "{#{types.argify}}".id %}
      {% gens = types.map { |t| "::Quick::GeneratorFor(#{t})".id } %}
      {% gens_tuple = "{#{gens.argify}}".id %}
      {% value_types = gens.map { |g| "typeof(#{g}.next)".id } %}
      {% value_types_tuple = "{#{value_types.argify}}".id %}

      %check = ::Quick::Check({{value_types_tuple}}).new({{name}}) do
        {
          {% for gen in gens %}
            {{gen}}.next,
          {% end %}
        }
      end.with_shrink_strategy do |values, prop|
        %values = ::Quick._tuple_assoc(values, {{gens.size}}, 0, values[0])

        {% for i in (0...gens.size) %}
          shrinked = ::Quick::ShrinkerFor({{gens[i]}}, {{value_types[i]}})
          .shrink(values[{{i}}]) do |value|
            prop.call(::Quick._tuple_assoc(%values, {{gens.size}}, {{i}}, value))
          end

          %values = ::Quick._tuple_assoc(%values, {{gens.size}}, {{i}}, shrinked)
        {% end %}

        %values
      end.check({{number_of_tests}}) do |%vars|
        {% if vars.size == 1 %}
          {{vars[0]}} = %vars[0]
        {% else %}
          {{vars.argify}} = %vars
        {% end %}

        {{block.body}}
      end

    {% else %}

      ::Quick::SimpleCheck.new({{name}}).check({{number_of_tests}}) do
        {{block.body}}
      end

    {% end %}
  end
end
