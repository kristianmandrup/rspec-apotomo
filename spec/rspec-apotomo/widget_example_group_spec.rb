require 'spec_helper'

module RSpec::Rails
  describe WidgetExampleGroup do
    context "as RSpec" do
      it "responds to render_widget" do
        group = RSpec::Core::ExampleGroup.describe do
          include WidgetExampleGroup
        end

        # Why is this weird? See https://github.com/rspec/rspec-core/issues/460
        # group.new.__should_for_example_group__ respond_to(:render_widget)
      end
    end

    context "as a test writer" do
      # A real user wouldn't use WidgetExampleGroup because
      # the rails rspec would include it automagically.
      include WidgetExampleGroup

      context "light-weight integration tests" do
        has_widgets do |root|
          root << widget(:dummy)
          root[:dummy].instance_eval do
            def apotomo_event_path(*args)
              "I should be mixed in properly from @routes"
            end
          end
        end

        it "should render a view" do
          render_widget(:dummy).text.chomp.should == "Hey from DummyWidget! I should be mixed in properly from @routes"
        end

        it "should support _path helpers from the controller" do
          # We have to stub include so that things determine the route exists.
          Rails.application.routes.named_routes.helpers.stub(:include?).and_return(:true)
          @controller.should_receive(:test_path).at_least(:once)
          test_path
        end

        it "should support polymorphic_path from the controller" do
          # We have to stub include so that things determine the route exists.
          Rails.application.routes.named_routes.helpers.stub(:include?).and_return(:true)
          @controller.should_receive(:test_path).at_least(:once)
          polymorphic_path(:test)
        end
      end

      context "- ::has_widget" do
        has_widgets do |root|
          root << widget(:dummy)
        end

        it "adds the widget to root" do
          root.find_widget(:dummy).should_not be_nil
        end
      end

      context "- #render_widget" do
        has_widgets do |root|
          root << widget(:dummy)
        end

        it "calls render_widget in apotomo's widget" do
          ::Apotomo::Widget.any_instance.should_receive(:render_widget)
          render_widget(:some_widget)
        end

        it "can use rendered to get the result of render_widget" do
          ::Apotomo::Widget.any_instance.stub(:render_widget).and_return("expected string")
          render_widget(:some_widget)
          rendered.should have_content 'expected string'
        end
      end

      context "- #trigger" do
        has_widgets do |root|
          root << widget(:dummy)
        end

        it "triggers events and returns the page updates" do
          DummyWidget.any_instance.stub(:doo).and_return("unexpected string")
          trigger(:doo, :dummy).should == ["unexpected string"]
        end
      end

      context "- #view_assigns" do
        has_widgets do |root|
          root << widget(:dummy)
        end

        it "gets the widget controller variables" do
          DummyWidget.class_eval do
            def show
              @user = "Justin"
            end
          end
          render_widget(:dummy, :show)
          view_assigns[:user].should == "Justin"
        end
      end
    end
  end
end
