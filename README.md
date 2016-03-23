# quick [![Build Status](https://travis-ci.org/waterlink/quick.cr.svg?branch=master)](https://travis-ci.org/waterlink/quick.cr)

QuickCheck implementation for Crystal Language.

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  quick:
    github: waterlink/quick.cr
```

## Usage

```crystal
require "quick"
```

### Property testing

- [ ] To be done

```crystal
Quick.check("add reflexivity") do |x : Int32, y : Int32|
  add(x, y) == add(y, x)
end
```

It raises `Quick::CheckFailedError` when property does not hold for some
values.

### Configuration

`Quick.check` accepts different keyword arguments, that can be combined:

- `Quick.check("property", number_of_tests: 100)` - `number_of_tests` controls,
  how much tests are generated to verify the property. Default: `100`.

### Control over generated data

`Quick.check` determines generator for the data from the type annotation of a
block arguments. Possible options:

- A basic type with default min/max limits:
  - [x] `x : Int32`,
  - [x] `s : String`,
  - [x] `f : Float64`,
  - [x] `b : Bool`,
  - [x] `a : Array(Int32)`,
  - [x] `p : Tuple(Int32, Float64)` (pair)
  - [x] `h : Hash(String, Float64)`
  - etc.
- [x] One of the range: `value : Quick::Range(13, 79)`
  - [x] `Quick::Range` is an alias for `Quick::Range32`, which works only with `Int32`
  - [x] `Quick::Range8` and `Quick::Range16` are available for corresponding `Int8` and `Int16` types
  - [x] `Quick::Range64` is available, but cannot be used with ranges out of `Int32` boundaries (see: crystal-lang/crystal#2353)
  - [x] `Quick::FloatRange` and `Quick::FloatRange64` for ranges of type `Float64`
  - [x] `Quick::FloatRange32` for ranges of type `Float32`
- [x] Array of specific size: `a : Quick::Array(Int32, 50)`
- [x] Array of generated size: `a : Quick::Array(Int32, Quick::Range(0, 1000))`
- [x] String of specific size: `s : Quick::String(15)`
- [x] String of generated size: `s : Quick::String(Quick::Range(0, 50))`
- [x] Numeric value for a size (same as `Int32`, but has smaller default limit 0..100): `size : Quick::Size`
- [ ] Pick one value from the list: `Quick.def_choice(ColorGen, "red", "blue", "green")` and use it as `value : ColorGen`
- [ ] Pick one generator from the list: `Quick.def_choice(RandomStuffGen, Int32, HelloWorldGen, ColorGen, FloatRange(2, 4), Bool)` and use it as `value : RandomStuffGen`

### Literal generator that returns same value

First define your own literal generator class, that will always return provided value:

```crystal
# it defines special HelloWorldGen type, that can be
# used in type annotations afterwards
Quick.def_literal(HelloWorldGen, "hello world")
```

And then use it:

```crystal
Quick.check("property") do |s : HelloWorldGen|
  s == "hello world"
end
```

### Building your own generator

- [ ] To be done

If you have your own custom data structure, that you want to generate data for,
you simply need to register its generator with `Quick`:

```crystal
record User, :email, :password

Quick.register_generator(User) do |email_size_generator : Quick::Generators::Size, password_size_generator : Quick::Generators::Size|
  User.new(
    Quick.string(email_size_generator.next) + "@example.org",
    Quick.string(password_size_generator.next)
  )
end
```

Then you should be able to use it as:

```crystal
Quick.check("valid user") do |user : Quick::Custom(User)|
  user.valid?
end

# or with custom size generators
Quick.check("valid user") do |user : Quick::Custom(User, 1..15, 10..25)|
  user.valid?
end
```

## Development

After cloning this repository, run `shards install` to install dependencies.

To run the test suite, use `crystal spec`.

## Contributing

1. Fork it ( https://github.com/waterlink/quick.cr/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [waterlink](https://github.com/waterlink) Oleksii Fedorov - creator,
  maintainer
