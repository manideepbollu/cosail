require 'rails_helper'

RSpec.describe "UsersSignups", type: :request do
  describe "GET /users_signups" do
    it "works!" do
      get users_signups_path
      expect(response).to have_http_status(200)
    end
  end
end
