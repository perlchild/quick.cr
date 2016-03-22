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
- [ ] A concrete value: `value: Quick::Literal(79)`
- [ ] One of the range: `value: Quick::Range(13..79)`
- [ ] Array of specific size: `a: Quick::Array(Int32, 50)`
- [ ] Array of generated size: `a: Quick::Array(Int32, 0..1000)`
- [ ] String of specific size: `s: Quick::String(15)`
- [ ] String of generated size: `s: Quick::String(0..50)`
- [ ] Numeric value of limited size: `i: Quick::Int32(-200..200)` or `f: Quick::Float64(-1..3)`
- [ ] Numeric value for a size (same as `Int32`, but has smaller default limit 0..100): `size: Quick::Size`
- [ ] Pick one value from the list: `value: Quick::Choose("red", "green", "blue")`
- [ ] Pick one generator from the list: `value: Quick::Choose(Int32, "hello world", Bool)`

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
