class ReadingsController < ApplicationController

  before_action :authenticate_user!
  before_action :set_reading, only: [:show, :destroy]
  before_action :set_profile, only: [:create_tarot, :create_horoscope]


#General readings

  def index
    @readings = current_user.readings.order(created_at: :desc)
  end

  def show
    if @reading.reading_type == "tarot"
      render :show_tarot
    elsif @reading.reading_type == "horoscope"
      render :show_horoscope
    else
      render :show
    end
  end

  def destroy
    @reading.destroy
    redirect_to readings_path, notice: "Reading deleted"
  end



#GET
  def new_horoscope
 @reading = Reading.new(reading_type: "horoscope")
  end

#POST
  def create_horoscope


   unless @profile
      redirect_to new_profile_path, alert: "Please create your profile first"
    return
   end

  @reading = current_user.readings.build
  @reading.reading_type = "horoscope"
  @reading.date = Date.today

  prompt = <<~PROMPT
        You are an expert astrologer. Generate a daily horoscope for this user based on their natal chart:
      - Date and time of birth: #{@profile.birth_datetime}
      - City of birth: #{@profile.birth_city}
      - Country of birth: #{@profile.birth_country}

      The horoscope should:
      - Be written in a friendly and positive tone
      - Mention emotional, work and health aspects.
      - Be max. 2 short paragraphs for the 3 categories.
      - include the title emotional life , health life and work life to separate the text.
       PROMPT

    chat     = RubyLLM::Chat.new
    response = chat.ask(prompt)

    @reading.content = response.content

    if @reading.save
      redirect_to reading_path(@reading), notice: "Horoscope generated successfully!"
     else
      render :new_horoscope, status: :unprocessable_entity
     end
  end
 #####################################

   #nueva fila vacia
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
      You are an expert astrologer.
      Generate a #{category} tarot reading based on this profile please use the Celtic Cross and discribe the 10 cards for deep analysis. Start mention the name and the zodiac sign:
     - Name: #{current_user.first_name}
     - Date and time of birth: #{@profile.birth_datetime}
     - city of birth: #{@profile.birth_city}
    - Country of birth: #{@profile.birth_country}
      The reading must be written in a friendly conversational style.
    PROMPT

    chat     = RubyLLM::Chat.new
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

  #def show
   # @reading = current_user.readings.find(params[:id])
  #end

end

private

  def set_reading
    @reading = current_user.readings.find(params[:id])
  end

  def reading_params
    params.require(:reading).permit(:category_tarot)
  end

  def set_profile
   @profile = current_user.profile
  end
