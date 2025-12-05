class ReadingsController < ApplicationController

  before_action :authenticate_user!


  def new_tarot
    @reading = Reading.new(reading_type: "tarot")
  end


  def create_tarot
    profile = current_user.profile

    unless profile
      redirect_to new_profile_path, alert: "Please create your profile first"
      return
    end

    @reading = current_user.readings.build(reading_params)
    @reading.reading_type = "tarot"
    @reading.date         = Date.today


    # Si no eligió categoría, por defecto "love"
    category = @reading.category_tarot.presence || "love"

    prompt = <<~PROMPT
      Generate a #{category} tarot reading based on this profile:
      Name: #{profile.name}
      Birthday: #{profile.birthdate}
      Birth city: #{profile.birth_city}
      Birth time: #{profile.birth_time}

      The reading must be written in a friendly conversational style.
    PROMPT

    chat     = RubyLLM::Chat.new(model: "gpt-4o-mini")
    response = chat.ask(prompt)
    @reading.content = response.content

    # 4. Guardar y redirigir
    if @reading.save
      redirect_to reading_path(@reading), notice: "Tarot generated successfully!"
    else
      # Usar 'new_tarot' para renderizar el formulario con errores
      render :new_tarot, status: :unprocessable_entity
    end
  end

  private


  def reading_params
    params.require(:reading).permit(:category_tarot)
  end

end
