require "./spec_helper"

Spec2.describe "Shrinking" do
  include SpecHelpers

  MIN_INT32 = Int32::MIN + 1

  alias Positive = Quick::Range(0, Int32::MAX)
  alias Negative = Quick::Range(MIN_INT32, 0)

  it "shrinks integers" do
    Quick.check("detects < step function (positive)", [step_at : Positive]) do
      caught([x : Int32]) { x < step_at }.when_caught do |args|
        args[0] == step_at
      end
    end

    Quick.check("detects < step function (negative)", [step_at : Negative]) do
      caught([x : Int32]) { x < step_at }.when_caught do |args|
        args[0] == 0
      end
    end

    Quick.check("detects > step function (positive)", [step_at : Positive]) do
      caught([x : Int32]) { x > step_at }.when_caught do |args|
        args[0] == 0
      end
    end

    Quick.check("detects > step function (negative)", [step_at : Negative]) do
      caught([x : Int64]) { x > step_at }.when_caught do |args|
        args[0] == step_at
      end
    end
  end

  it "shrinks ranges" do
    Quick.check("detects < step function (positive)", [step_at : Positive]) do
      caught([x : Positive]) { x < step_at }.when_caught do |args|
        args[0] == step_at
      end
    end

    Quick.check("detects < step function (> custom range)", [step_at : Quick::Range(37, 55)]) do
      caught([x : Quick::Range(55, 69)]) { x < step_at }.when_caught do |args|
        args[0] == 55
      end
    end

    Quick.check("detects < step function (< custom range)", [step_at : Quick::Range(56, 90)]) do
      caught([x : Quick::Range(55, 69)]) { x < step_at }.when_caught do |args|
        args[0] == step_at
      end
    end

    Quick.check("detects > step function (> custom range)", [step_at : Quick::Range(60, 92)]) do
      caught([x : Quick::Range(55, 69)]) { x > step_at }.when_caught do |args|
        args[0] == 55
      end
    end

    Quick.check("detects > step function (< custom range)", [step_at : Quick::Range(37, 69)]) do
      caught([x : Quick::Range(55, 69)]) { x > step_at }.when_caught do |args|
        args[0] == 55
      end
    end

    Quick.check("detects > step function (> custom range, negative)", [step_at : Quick::Range(-92, -60)]) do
      caught([x : Quick::Range(-69, -55)]) { x > step_at }.when_caught do |args|
        args[0] == step_at
      end
    end
  end

  it "shrinks arrays of integers" do
    Quick.check("when order of 2 elements is important only 2 elements are left") do
      caught([a : Array(Int32)]) { is_ordered(a) }.when_caught do |args|
        args[0].size == 2
      end
    end

    Quick.check("when order of 2 elements is important only elements are shrinked") do
      caught([a : Array(Int32)]) { is_ordered(a) }.when_caught do |args|
        args[0] == [0, -1] ||
          args[0] == [1, 0]
      end
    end
  end

  it "shrinks strings" do
    Quick.check("shrinks size of the string") do
      caught([s : String]) { is_palindrom(s) }.when_caught do |args|
        args[0].size == 2
      end
    end
  end

  it "shrinks floats" do
    Quick.check("shrinks floats (32 bit)", [step_at_i : Positive]) do
      step_at = step_at_i / 10.0
      eps = step_at * (0.1 ** 5)
      caught([f : Float32]) { f < step_at }.when_caught do |args|
        (args[0] - step_at).abs < eps
      end
    end

    Quick.check("shrinks floats (64 bit)", [step_at_i : Positive]) do
      step_at = step_at_i / 10.0
      eps = step_at * (0.1 ** 5)
      caught([f : Float64]) { f < step_at }.when_caught do |args|
        (args[0] - step_at).abs < eps
      end
    end
  end

  it "shrinks hashes" do
    Quick.check("reduces size of the hash") do
      caught([h : Hash(String, Quick::Range(0, 100))]) do
        reverse_hash(reverse_hash(h)) == h
      end.when_caught do |args|
        args[0].size == 2
      end
    end

    Quick.check("shrinks keys") do
      caught([h : Hash(String, Quick::Range(0, 100))]) do
        reverse_hash(reverse_hash(h)) == h
      end.when_caught do |args|
        args[0].keys.all? { |k| k.size < 2 }
      end
    end
  end

  it "shrinks for multiple arguments" do
    failed = (0..100).map do
      caught([x : Quick::Range(-100, 100), y : Quick::Range(-100, 100)]) { x == y }.when_caught do |args|
        args.all? { |x| x.abs <= 1 }
      end
    end.count(false)

    # There is small chance that max shrinking is not possible, example:
    # - {92, 85} => {91, 85} => {89, 85} => {85, 85} => STOP
    # Therefore this test only verifies, that majority of times it shrinks correctly
    expect(failed).to_be < 3
  end

  def is_ordered(a : Array(Int32))
    a.each_cons(2).all? do |v|
      a, b = v
      a <= b
    end
  end

  def is_palindrom(s : String)
    s == s.reverse
  end

  def reverse_hash(h : Hash(K, V))
    r = {} of V => K
    h.each do |k, v|
      r[v] = k
    end
    r
  end
end
