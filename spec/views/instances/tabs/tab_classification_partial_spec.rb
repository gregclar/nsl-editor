# frozen_string_literal: true

require "rails_helper"

RSpec.describe "instances/tabs/_tab_classification.html.erb", type: :view do
  let(:user) { FactoryBot.create(:user) }
  let(:instance) { FactoryBot.create(:instance) }
  let(:working_draft) { double("TreeVersion", id: 1) }

  def stub_workspace_tab_partial
    stub_template "instances/workspace/_tab_main.html.erb" => "<div id='workspace-tab-main'>Workspace Tab Main</div>"
  end

  before do
    assign(:instance, instance)
    allow(view).to receive(:increment_tab_index).and_return(0)
  end

  context "when @working_draft is not present" do
    before do
      assign(:working_draft, nil)
    end

    it "renders a message about no draft taxonomy selected" do
      render
      expect(rendered).to have_content("No draft taxonomy selected")
      expect(rendered).to have_content("Select a draft taxonomy from the Draft Taxonomies menu")
    end
  end

  context "when @working_draft is present" do
    before do
      assign(:working_draft, working_draft)
    end

    context "when user cannot place names in the draft" do
      before do
        allow(view).to receive(:can?).with(:place_name, working_draft).and_return(false)
      end

      it "renders a permission denied message" do
        render
        expect(rendered).to have_content("You do not have permission to place names in this draft taxonomy")
      end
    end

    context "when user can place names in the draft" do
      before do
        allow(view).to receive(:can?).with(:place_name, working_draft).and_return(true)
      end

      context "when multi_product_tabs_enabled is false" do
        before do
          allow(Rails.configuration).to receive(:try).with("multi_product_tabs_enabled").and_return(false)
          stub_workspace_tab_partial
        end

        it "renders the workspace tab_main partial" do
          render
          expect(rendered).to render_template(partial: "instances/workspace/_tab_main")
        end
      end

      context "when multi_product_tabs_enabled is true" do
        before do
          allow(Rails.configuration).to receive(:try).with("multi_product_tabs_enabled").and_return(true)
        end

        context "when current_product_from_context matches the instance" do
          let(:matching_product) { double("Product", has_the_same_reference?: true) }

          before do
            view.define_singleton_method(:current_product_from_context) { matching_product }
            view.define_singleton_method(:current_registered_user) { user }
            allow(user).to receive(:roles).and_return(["some_role"])
            stub_workspace_tab_partial
          end

          it "renders the workspace tab_main partial" do
            render
            expect(rendered).to render_template(partial: "instances/workspace/_tab_main")
          end
        end

        context "when current_product_from_context does not match the instance" do
          before do
            view.define_singleton_method(:current_product_from_context) { nil }
          end

          context "and user has blank roles" do
            before do
              allow(user).to receive(:roles).and_return([])
              view.define_singleton_method(:current_registered_user) { user }
              stub_workspace_tab_partial
            end

            it "renders the workspace tab_main partial" do
              render
              expect(rendered).to render_template(partial: "instances/workspace/_tab_main")
            end
          end

          context "and user has roles" do
            before do
              allow(user).to receive(:roles).and_return(["some_role"])
              view.define_singleton_method(:current_registered_user) { user }
            end

            it "renders the permission denied message" do
              render
              expect(rendered).to have_content("You do not have permission to place names in this draft taxonomy")
            end
          end
        end
      end
    end
  end
end
