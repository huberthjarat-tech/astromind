class ProfilesController < ApplicationController
before_action :authenticate_user!

  def new
  @profile = Profile.new  #empty object for the form.
  end

  def create
  @profile = Profile.new (profile_params)
  @profile.user = current_user
  end


end
