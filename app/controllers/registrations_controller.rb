class RegistrationsController < Devise::RegistrationsController
  def edit
    if current_user.facebook?
      flash[:warning] = 'Facebook users are not allowed to maintain their registration details manually.'
      redirect_to dashboard_path
    else
      super
    end
  end
end