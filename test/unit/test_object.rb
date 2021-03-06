require File.expand_path("../../test_helper", __FILE__)

module Unit
  class TestObject < MiniTest::Unit::TestCase

    describe "An object instance" do
      before do
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
        private
          def id
            "C"
          end
        end
        @c = C.new
        @c.title = "Mr."
      end

      it "should respond to meta_class and extended_modules" do
        assert @c.respond_to?(:meta_class)
        assert @c.meta_class.respond_to?(:extended_modules)
      end

      describe "when extending modules" do
        it "should check whether a module is unextendable or not" do
          module B; end

          A.expects(:unextendable?).twice
          B.expects(:unextendable?)

          @c.extend A
          @c.extend A, B

          assert @c.meta_class.included_modules.include?(A)
          assert @c.meta_class.included_modules.include?(B)
        end

        describe "which are not unextendable" do
          it "should behave as normal when the module is not unextendable" do
            A.expects(:wrap_unextendable_module).never
            @c.extend A
            assert @c.meta_class.included_modules.include?(A)
            assert @c.meta_class.extended_modules.include?(A)
          end

          it "should behave as expected" do
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

        describe "which are unextendable" do
          before do
            module B
              unextendable
            public
              def id
                "B"
              end
            end

            module U
              unextendable
              def name
                "U"
              end
              def foo
                "bar"
              end
            private
              def id
                "U"
              end
            end
          end

          it "should respond to a non-extended instance method after extending" do
            assert @c.respond_to?(:salutation)
            @c.extend U
            assert @c.respond_to?(:salutation)
          end

          it "should call wrap_unextendable_module" do
            @c.expects(:wrap_unextendable_module)
            @c.extend A, U
          end

          it "should call wrap_unextendable_method" do
            @c.expects(:wrap_unextendable_method).times(3)
            @c.extend U
          end

          it "should add nil value as method proc when not responding to module method name" do
            @c.extend U
            assert_equal 1, @c.meta_class.method_procs.select{|k, v| v.nil?}.size
            assert_equal 2, @c.meta_class.method_procs.select{|k, v| v.class == Proc}.size
          end

          it "should add the module to extended_modules" do
            assert @c.meta_class.extended_modules.empty?
            @c.extend U
            assert @c.meta_class.extended_modules.include?(U)
          end

          it "should add method proc to method_procs" do
            assert @c.meta_class.send(:method_procs).empty?
            @c.extend U
            assert_equal 3, @c.meta_class.send(:method_procs).size
          end

          describe "when calling an unextendable method" do
            it "should call call_unextendable_method" do
              @c.extend U
              @c.expects(:call_unextendable_method).with(:name)
              @c.name
            end

            it "should call method_for" do
              method = @c.meta_class.instance_method(:name).bind(@c)
              @c.extend U
              @c.expects(:method_for).with(:name).returns(method)
              @c.name
            end

            it "should match the expected method" do
              assert_equal @c.method(:name), @c.send(:method_for, :name)
              @c.extend U
              assert_equal U.instance_method(:name).bind(@c), @c.send(:method_for, :name)
            end

            it "should return the expected value" do
              assert_equal "Mr. C", @c.salutation
              @c.extend U
              assert_equal "Mr. U", @c.salutation

              @d = C.new
              assert_equal "C", @d.salutation
              @d.extend U
              assert_equal "U", @d.salutation
            end
          end

          describe "when unextending the module afterwards" do
            it "should remove the module from extended_modules" do
              exception = assert_raises(NoMethodError) do
                @c.id
              end
              assert_equal "private method `id' called for", exception.message[0..29]
              assert_equal "C", @c.send(:id)

              @c.extend U
              assert @c.meta_class.extended_modules.include?(U)
              assert_equal "private method `id' called for", exception.message[0..29]
              assert_equal "U", @c.send(:id)

              @c.extend B
              assert_equal "B", @c.send(:id)

              @c.unextend
              assert !@c.meta_class.extended_modules.include?(U)
              assert_equal "private method `id' called for", exception.message[0..29]
              assert_equal "C", @c.send(:id)
            end

            it "should remove the module but when passed a block only when it passes" do
              assert_equal "Mr. C", @c.salutation

              @c.extend U
              assert_equal "Mr. U", @c.salutation

              @c.unextend do |mod|
                mod != U
              end
              assert_equal "Mr. U", @c.salutation

              @c.unextend do |mod|
                mod == U
              end
              assert_equal "Mr. C", @c.salutation
            end

            describe "when calling an unextendable method" do
              it "should match the expected method" do
                assert_equal @c.method(:name), @c.send(:method_for, :name)

                @c.extend U
                assert_equal U.instance_method(:name).bind(@c), @c.send(:method_for, :name)

                @c.unextend U
                assert_equal Proc, @c.send(:method_for, :name).class
              end

              it "should behave as expected" do
                assert_equal "Mr. C", @c.salutation
                @c.title = "Dr."
                assert_equal "Dr. C", @c.salutation

                assert !@c.respond_to?(:foo)
                assert_raises NoMethodError do
                  @c.foo
                end

                @c.extend U
                assert_equal "Dr. U", @c.salutation
                @c.title = "Sir"
                assert_equal "Sir U", @c.salutation

                assert @c.respond_to?(:salutation)
                assert @c.respond_to?(:foo)
                @c.foo
                assert_equal "bar", @c.foo

                @c.unextend U
                assert_equal "Sir C", @c.salutation
                @c.title = ""
                assert_equal "C", @c.salutation

                assert  @c.respond_to?(:salutation)
                assert !@c.respond_to?(:foo)
                assert_raises NoMethodError do
                  @c.foo
                end

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

                @c.extend U
                @c.unextend do |mod|
                  mod != U
                end
                assert_equal "Ms. U", @c.salutation

                @c.unextend do |mod|
                  mod == U
                end
                assert_equal "Ms. A", @c.salutation
              end
            end
          end
        end
      end
    end

  end
end