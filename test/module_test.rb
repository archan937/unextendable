require File.expand_path("../test_helper", __FILE__)

class ModuleTest < Test::Unit::TestCase

  context "A module" do
    setup do
      module A
      end
    end

    should "be able to be marked as unextendable" do
      assert A.respond_to?(:unextendable)
    end

    should "respond to :unextendable?" do
      assert A.respond_to?(:unextendable?)
    end

    context "which is not unextendable" do
      should "return false when asked to be unextendable" do
        assert !A.unextendable?
      end
    end

    context "which is unextendable" do
      setup do
        module U
          unextendable
          def name
            "U"
          end
        end
      end

      should "return true when asked to be unextendable" do
        assert U.unextendable?
      end
    end
  end

end