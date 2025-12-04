class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?

  skip_before_action :authenticate_user!, only: :home

  #after sign_up
  def after_sign_up_path_for(resource)
    new_profile_path
  end

  # after login
  def after_sign_in_path_for(resource)
    if current_user.profile.present?
      profile_path
    else
      new_profile_path
    end
  end



  def configure_permitted_parameters
    # For additional fields in app/views/devise/registrations/new.html.erb
    devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name, :last_name])
    # For additional in app/views/devise/registrations/edit.html.erb
    devise_parameter_sanitizer.permit(:account_update, keys: [:first_name, :last_name])
  end

  def home
  end
end
