class ProfilesController < ApplicationController
before_action :authenticate_user!        #must be login

  def new
    redirect_to profile_path if current_user.profile.present?

    @profile = Profile.new  #here we create the empty object
  end

  def create
  @profile = Profile.new (profile_params)
  @profile.user= current_user   #asociated this profile with the user already login

    if @profile.save          #validate inside the model
      redirect_to profile_path, notice: "You have a profile now" #here the active record get the ID to build the url
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
  @profile = current_user.profile
  redirect_to new_profile_path unless @profile
  end

  private

  def profile_params        #security rules
    params.require(:profile).permit(:birth_datetime, :birth_city, :birth_country)
  end
end
