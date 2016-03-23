require "./spec_helper"

Spec2.describe "Quick.check(property) { body }" do
  include Quick

  context "without arguments" do
    it "works" do
      Quick.check("a property") { true }
    end

    it "fails with CheckFailedError when body is false" do
      expect do
        Quick.check("a property") { false }
      end.to raise_error(CheckFailedError(Nil))
    end

    it "runs provided body #{DEFAULT_TEST_COUNT} times" do
      times_run = 0
      Quick.check("a property") do
        times_run += 1
        true
      end

      expect(times_run).to eq(DEFAULT_TEST_COUNT)
    end

    it "runs provided body specified amount of times" do
      times_run = 0
      Quick.check("a property", number_of_tests: 50) do
        times_run += 1
        true
      end

      expect(times_run).to eq(50)
    end

    it "fails even when only some block runs return false" do
      times_run = 0
      expect do
        Quick.check("a property") do
          times_run += 1
          times_run < DEFAULT_TEST_COUNT - 5
        end
      end.to raise_error(CheckFailedError(Nil))

      times_run = 0
      expect do
        Quick.check("a property") do
          times_run += 1
          times_run > DEFAULT_TEST_COUNT - 5
        end
      end.to raise_error(CheckFailedError(Nil))
    end
  end

  context "with simple arguments" do
    it "works when arguments are of same type" do
      Quick.check("a property", [value : Int32]) do
        value.is_a?(Int32)
      end

      expect do
        Quick.check("a property", [value : Int32]) do
          value.is_a?(String)
        end
      end.to raise_error(CheckFailedError({Int32}))

      Quick.check("a property", [x : Int32, y : Int32]) do
        x.is_a?(Int32) && y.is_a?(Int32)
      end
    end

    it "works when arguments are of different type" do
      Quick.check("a property", [x : Int32, y : ::String]) do
        x.is_a?(Int32) && y.is_a?(::String)
      end

      Quick.check("a property", [x : Range(100, 200), y : String(20)], number_of_tests: 200) do
        x.is_a?(Int32) && y.is_a?(::String) &&
          100 <= x < 200 &&
          0 <= y.size <= 20
      end
    end
  end

  describe CheckFailedError do
    it "provides failed arguments and property name" do
      got_check_failed_error = false

      name = "each array includes each number"
      begin
        Quick.check(name, [x : Array(Int32, 5), y : Int32]) do
          x.includes?(y)
        end
      rescue e : CheckFailedError({::Array(Int32), Int32})
        got_check_failed_error = true
        x, y = e.failed_args
        expect(x.includes?(y)).to eq(false)
        expect(e.property_name).to eq(name)
      end

      expect(got_check_failed_error).to eq(true)
    end

    it "provides a descriptive message" do
      expect(CheckFailedError.new("a property", {[37, 42], 24}).message)
        .to eq("Property 'a property' failed\n\twith arguments: {[37, 42], 24}")
    end
  end
end
