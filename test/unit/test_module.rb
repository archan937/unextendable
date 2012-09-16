require File.expand_path("../../test_helper", __FILE__)

module Unit
  class TestModule < MiniTest::Unit::TestCase

    describe "A module" do
      before do
        module A
        end
      end

      it "should be able to be marked as unextendable" do
        assert A.respond_to?(:unextendable)
      end

      it "should respond to :unextendable?" do
        assert A.respond_to?(:unextendable?)
      end

      describe "which is not unextendable" do
        it "should return false when asked to be unextendable" do
          assert !A.unextendable?
        end
      end

      describe "which is unextendable" do
        before do
          module U
            unextendable
            def name
              "U"
            end
          end
        end

        it "should return true when asked to be unextendable" do
          assert U.unextendable?
        end
      end
    end

  end
end