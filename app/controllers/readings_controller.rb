class ReadingsController < ApplicationController

  before_action :authenticate_user!
  before_action :set_reading, only: [:show, :destroy]
  before_action :set_profile, only: [:create_tarot, :create_horoscope]


  def dashboard
    # 1. Leer parámetros del formulario (pueden venir vacíos)
    @selected_month       = params[:month]
    @selected_year        = params[:year]
    @selected_type        = params[:reading_type]    # "tarot" o "horoscope"
    @selected_category    = params[:category_tarot]  # "love", "money", "health"

    # 2. Empezamos con todas las lecturas del usuario
    @readings = current_user.readings.order(date: :desc)

    # 3. Filtrar por mes y año si están presentes
    if @selected_year.present? && @selected_month.present?
      start_date = Date.new(@selected_year.to_i, @selected_month.to_i, 1)
      end_date   = start_date.end_of_month
      @readings  = @readings.where(date: start_date..end_date)
    end

    # 4. Filtrar por tipo de lectura (tarot / horoscope)
    if @selected_type.present?
      @readings = @readings.where(reading_type: @selected_type)
    end

    # 5. Filtrar por categoría de tarot (solo tiene sentido si es tarot)
    if @selected_category.present?
      @readings = @readings.where(category_tarot: @selected_category)
    end
  end


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
    redirect_to dashboard_path, notice: "Reading deleted"
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
      - Be written in a friendly and positive tone and mention the zodial sign
      - Mention emotional, work and health aspects.
      - Be max. 2 short paragraphs for the 3 categories.
      - include the title emotional life , health life and work life to separate the text.


        IMPORTANT FORMATTING RULES:
          2. For each of the 3 paragraph, use EXACTLY this format:

            1. Emotional Life
            [Description ]

            2. Health Life
            [Description ]

            3. work Life
            [Description ]

          4. Use a clear line break between cards
          5. Write in a friendly, conversational style
          6. Do NOT use asterisks (**) or hashtags (###) in your response

          Example format:

          1. Emotional Life
          This card sitting at the heart of your reading suggests...

          2. Health Life
          Sometimes, past disappointments or regrets...

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
    Generate a #{category} tarot reading based on this profile using the Celtic Cross spread.

    Profile:
    - Name: #{current_user.first_name}
    - Date and time of birth: #{@profile.birth_datetime}
    - City of birth: #{@profile.birth_city}
    - Country of birth: #{@profile.birth_country}

    IMPORTANT FORMATTING RULES:
    1. Start with a friendly greeting mentioning the user's name and zodiac sign
    2. For each of the 10 cards, use EXACTLY this format:


Future — What is developing
Conscious influence — What the user is aware of
Unconscious influence — Hidden emotional patterns
User’s attitude
External factors
Hopes and fears
Outcome — The direction things are moving toward

        1. Present — Card Name
       [Description of the card's meaning]
        2. Challenge — Card Name
       [Description of the card's meaning]
        3. Past — Card Name
        [Description of the card's meaning]
        4. Future — Card Name
        [Description of the card's meaning]
        5. Conscious — Card Name
        [Description of the card's meaning]
        6. Unconscious — Card Name
        [Description of the card's meaning]
        7. Attitude — Card Name
        [Description of the card's meaning]
        8. External Factors  — Card Name
        [Description of the card's meaning]
        9. Hope and Fears — Card Name
        [Description of the card's meaning]
        10. Outcome — Card Name
        [Description of the card's meaning]

    3. Each card number MUST be on its own line
    4. Use a clear line break between cards
    5. Write in a friendly, conversational style
    6. Do NOT use asterisks (**) or hashtags (###) in your response

    Example format:
    Hello [Name]! Based on your birth details...

    1. The Present Situation — The Lovers
    This card sitting at the heart of your reading suggests...

    2. The Challenge — The Five of Cups
    Sometimes, past disappointments or regrets...

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
