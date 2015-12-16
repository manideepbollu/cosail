require 'rails_helper'

RSpec.describe PortsController, type: :controller do

  describe "GET #suggest" do
    it "returns http success" do
      get :suggest
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #route" do
    it "returns http success" do
      get :route
      expect(response).to have_http_status(:success)
    end
  end

end
