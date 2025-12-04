class ReadingsController < ApplicationController
before_action :authenticate_user!
  before_action :set_reading   # @reading para aplciar a todos las acciones


def show
    @tarot = @reading.reading_type
    @has_tarp = @tarot.present?

end


def create
end




  def set_profile
    @reading = current_user.profile
  end
end
