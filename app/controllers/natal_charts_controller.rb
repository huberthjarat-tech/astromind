class NatalChartsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_profile   # @profile para aplciar a todos las acciones

  # GET /natal_chart
  def show
    @natal_chart = @profile.natal_chart_text
    @has_natal_chart = @natal_chart.present?
  end

  # POST /natal_chart

  def create
     raise 
    if @profile.natal_chart_text.present?   # stop boton Generate-more than once
      redirect_to natal_chart_path, notice: "You already have a natal chart!"
      return
    end

  #  OpenAI


    natal_chart_text = ## OPEN AI


    # Guardar en el perfil
    if @profile.update(natal_chart_text: natal_chart_text)
      redirect_to natal_chart_path, notice: "Great! enjoy your natal chart"
    else
      redirect_to natal_chart_path, alert: "There was an error.Please try again."
    end
  end

  private

  def set_profile
    @profile = current_user.profile
  end
end
