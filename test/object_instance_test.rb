require File.expand_path("../test_helper", __FILE__)

class ObjectInstanceTest < Test::Unit::TestCase

  context "An object instance" do
    setup do
      module A
        def name
          "A"
        end
      end
      class C
        attr_accessor :title
        def salutation
          [title, name].reject{|x| x.nil? || x.empty?}.join " "
        end
        def name
          "C"
        end
      end
      @c = C.new
      @c.title = "Mr."
    end

    should "respond to meta_class and extended_modules" do
      assert @c.respond_to?(:meta_class)
      assert @c.meta_class.respond_to?(:extended_modules)
    end

    context "when extending modules" do
      should "check whether a module is unextendable or not" do
        module B; end

        A.expects(:unextendable?).twice
        B.expects(:unextendable?)

        @c.extend A
        @c.extend A, B

        assert @c.meta_class.included_modules.include?(A)
        assert @c.meta_class.included_modules.include?(B)
      end

      context "which are not unextendable" do
        should "behave as normal when the module is not unextendable" do
          A.expects(:wrap_unextendable_module).never
          @c.extend A
          assert @c.meta_class.included_modules.include?(A)
          assert @c.meta_class.extended_modules.include?(A)
        end

        should "behave as expected" do
          assert_equal "Mr. C", @c.salutation

          @c.extend A
          assert_equal "Mr. A", @c.salutation

          @c.unextend
          assert_equal "Mr. A", @c.salutation

          @d = C.new
          @d.title = "Mr."
          assert_equal "Mr. C", @d.salutation

          @d.extend A
          assert_equal "Mr. A", @d.salutation

          @d.unextend A
          assert_equal "Mr. A", @d.salutation
        end
      end

      context "which are unextendable" do
        setup do
          module U
            unextendable
            def name
              "U"
            end
          end
        end

        should "call wrap_unextendable_module" do
          @c.expects(:wrap_unextendable_module)
          @c.extend A, U
        end

        should "call wrap_unextendable_method" do
          @c.expects(:wrap_unextendable_method)
          @c.extend U
        end

        should "add the module to extended_modules" do
          assert @c.meta_class.extended_modules.empty?
          @c.extend U
          assert @c.meta_class.extended_modules.include?(U)
        end

        should "add method proc to method_procs" do
          assert @c.meta_class.send(:method_procs).empty?
          @c.extend U
          assert_equal 1, @c.meta_class.send(:method_procs).size
        end

        context "when calling an unextendable method" do
          should "call call_unextendable_method" do
            @c.extend U
            @c.expects(:call_unextendable_method).with(:name)
            @c.name
          end

          should "call method_for" do
            method = @c.meta_class.instance_method(:name).bind(@c)
            @c.extend U
            @c.expects(:method_for).with(:name).returns(method)
            @c.name
          end

          should "match the expected method" do
            assert_equal @c.method(:name), @c.send(:method_for, :name)
            @c.extend U
            assert_equal U.instance_method(:name).bind(@c), @c.send(:method_for, :name)
          end

          should "return the expected value" do
            assert_equal "Mr. C", @c.salutation
            @c.extend U
            assert_equal "Mr. U", @c.salutation

            @d = C.new
            assert_equal "C", @d.salutation
            @d.extend U
            assert_equal "U", @d.salutation
          end
        end

        context "when unextending the module afterwards" do
          should "remove the module from extended_modules" do
            @c.extend U
            assert @c.meta_class.extended_modules.include?(U)

            @c.unextend U
            assert !@c.meta_class.extended_modules.include?(U)
          end

          context "when calling an unextendable method" do
            should "match the expected method" do
              assert_equal @c.method(:name), @c.send(:method_for, :name)

              @c.extend U
              assert_equal U.instance_method(:name).bind(@c), @c.send(:method_for, :name)

              @c.unextend U
              assert_equal Proc, @c.send(:method_for, :name).class
            end

            should "behave as expected" do
              assert_equal "Mr. C", @c.salutation
              @c.title = "Dr."
              assert_equal "Dr. C", @c.salutation

              @c.extend U
              assert_equal "Dr. U", @c.salutation
              @c.title = "Sir"
              assert_equal "Sir U", @c.salutation

              @c.unextend U
              assert_equal "Sir C", @c.salutation
              @c.title = ""
              assert_equal "C", @c.salutation

              @c.extend U
              assert_equal "U", @c.salutation
              @c.title = "Ms."
              assert_equal "Ms. U", @c.salutation

              @c.unextend
              assert_equal "Ms. C", @c.salutation

              module D
                unextendable
                def name
                  "D"
                end
              end

              @c.extend D
              assert_equal "Ms. D", @c.salutation

              @c.extend U
              assert_equal "Ms. U", @c.salutation

              @c.extend D
              assert_equal "Ms. D", @c.salutation

              @c.unextend
              assert_equal "Ms. C", @c.salutation

              @c.extend A
              assert_equal "Ms. A", @c.salutation

              @c.unextend
              assert_equal "Ms. A", @c.salutation

              @c.extend D
              assert_equal "Ms. D", @c.salutation

              @c.unextend
              assert_equal "Ms. A", @c.salutation
            end
          end
        end
      end
    end
  end

end