require 'rails_helper'

RSpec.describe RespondWithTurbo, type: :controller do
  describe '#respond_to_action' do
    context 'when the action is successful' do
      it 'redirects to the specified path with a notice' do
        user = create(:user)
        get :show, params: { id: user.id }
        expect(response).to redirect_to(user)
        expect(flash[:notice]).to eq("Success!")
      end

      it 'renders the fallback partial with a success status code' do
        user = create(:user, name: nil)
        get :show, params: { id: user.id }
        expect(response).to render_template(:fallback)
        expect(response.status).to eq(200)
      end
    end

    context 'when the action is not successful' do
      it 'renders the fallback partial with an error status code' do
        user = create(:user, name: nil)
        get :show, params: { id: user.id }
        expect(response).to render_template(:fallback)
        expect(response.status).to eq(422)
      end
    end
  end
end
