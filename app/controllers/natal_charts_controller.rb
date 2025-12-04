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

    if @profile.natal_chart_text.present?   # stop boton Generate-more than once
      redirect_to natal_chart_path, notice: "You already have a natal chart!"
      return
    end

  #  OpenAI

    chat = RubyLLM.chat.with_temperature(0.7)
    prompt = <<-PROMPT
      You are an expert astrologer.
      Generate a friendly natal chart reading in english based on this user's birth data.
      Data from the user:
      - Name: #{current_user.first_name}
      - Date and time of birth: #{@profile.birth_datetime}
      - city of birth: #{@profile.birth_city}
      - Country of birth: #{@profile.birth_country}

      Write in english, with a warm, positive, and clear tone.
      - 3 to 5 paragraphs, without lists or bullet points.
      - Use title to categorize.
      - Explain personality traits, challenges, and potential.
      - End with a guiding phrase for the future.

       Return only the reading text, without extra technical explanations

      PROMPT
    response = chat.ask(prompt)
    natal_chart_text = response.content


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
