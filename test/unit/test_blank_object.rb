require File.expand_path("../../test_helper", __FILE__)

module Unit
  class TestBlankObject < MiniTest::Unit::TestCase

    # ==================================================================================================================================
    # A BlankObject class is considered not to have meta_class and unextend defined, but does respond to extend (e.g. Liquid::Strainer)
    # See also: http://rubydoc.info/gems/liquid/2.3.0/Liquid/Strainer
    # ==================================================================================================================================

    describe "A blank object instance" do
      before do
        module Hi
          unextendable
          def say_hi
            "Hi!"
          end
        end
        class BlankObject
          def meta_class
            raise NoMethodError
          end
          def unextend
            raise NoMethodError
          end
          def respond_to?(symbol, include_private = false)
            return false if %w(meta_class unextend).include? symbol.to_s
            super
          end
        end
      end

      it "should have extend defined" do
        assert BlankObject.new.extend(Hi)
      end

      it "should not have meta_class and unextend defined" do
        assert_raises NoMethodError do
          BlankObject.new.meta_class
        end
        assert_raises NoMethodError do
          BlankObject.new.unextend
        end
      end

      it "should be extendable" do
        b = BlankObject.new
        b.extend Hi
        assert_equal "Hi!", b.say_hi
      end
    end

  end
end