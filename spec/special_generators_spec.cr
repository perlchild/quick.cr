require "./spec_helper"

Spec2.describe "Special generators" do
  include Quick

  macro describe_literal_generator(generator, value)
    describe "l : {{generator}}" do
      subject(generator) { GeneratorFor({{generator}}) }

      it "returns an Int32" do
        expect(generator.next).to be_a(typeof({{value}}))
        expect(typeof(generator.next)).to eq(typeof({{value}}))
      end

      it "always returns a specified literal value" do
        100.times do
          expect(generator.next).to eq({{value}})
        end
      end
    end
  end

  Literal.def_generator(AnswerOfTheUniverseGen, 42)
  describe_literal_generator(AnswerOfTheUniverseGen, value = 42)

  Literal.def_generator(HelloWorldGen, "hello world")
  describe_literal_generator(HelloWorldGen, value = "hello world")

  Literal.def_generator(SomeArrayGen, [1, 2, 4, 3])
  describe_literal_generator(SomeArrayGen, value = [1, 2, 4, 3])
end
