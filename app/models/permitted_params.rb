class PermittedParams < Struct.new(:params, :current_user)
  def itinerary
    params.require(:itinerary).permit(*itinerary_attributes)
  end

  def itinerary_attributes
    basic_fields = [:start_address, :end_address, :start_port_id, :end_port_id, :start_coords, :end_coords, :route_path, :description, :num_people, :smoking_allowed, :pets_allowed, :price, :days_at_sea,
                    :round_trip, :leave_date, :return_date, :daily, :share_on_facebook_timeline]
    basic_fields << :pink if current_user && current_user.female?
    basic_fields
  end

  def create_user
    params.require(:user).permit(*create_user_attributes)
  end

  def create_user_attributes
    [:name, :email, :password, :password_confirmation, :gender, :birthday]
  end

  def update_user
    params.require(:user).permit(*update_user_attributes)
  end

  def update_user_attributes
    [:time_zone, :locale, :vehicle_avg_consumption, :send_email_messages, :send_email_references]
  end

  def feedback
    params.require(:feedback).permit(*feedback_attributes)
  end

  def feedback_attributes
    basic_fields = [:type, :message, :url]
    basic_fields << :status if current_user && current_user.admin?
    basic_fields
  end

  def conversation
    params.require(:conversation).permit(*conversation_attributes)
  end

  def conversation_attributes
    [message: [:body]]
  end

  def reference
    params.require(:reference).permit(*reference_attributes)
  end

  def reference_attributes
    [:body, :rating]
  end
end
