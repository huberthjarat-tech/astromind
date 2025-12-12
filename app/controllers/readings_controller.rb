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

You are an expert astrologer specializing in the Rider-Waite Smith Tarot deck.
    Generate a #{@reading.category_tarot} tarot reading using the Celtic Cross spread.

    Profile:
    - Name: #{current_user.first_name}
    - Date and time of birth: #{@profile.birth_datetime}
    - City of birth: #{@profile.birth_city}
    - Country of birth: #{@profile.birth_country}

    ═══════════════════════════════════════════════════════════════════
    CRITICAL INSTRUCTIONS:
    ═══════════════════════════════════════════════════════════════════

    1. You will perform a REAL Celtic Cross Tarot reading
    2. Select 10 cards from the Rider-Waite Smith deck based on the person's profile
    3. Each card should be chosen intuitively based on their situation
    4. Provide genuine tarot guidance, not generic advice

    ═══════════════════════════════════════════════════════════════════
    FORMATTING REQUIREMENTS - FOLLOW EXACTLY:
    ═══════════════════════════════════════════════════════════════════

    1. Start with a warm greeting (1-2 sentences):
       "Hello [Name]! As a [Zodiac Sign], you have [brief trait]. Let's explore what the Tarot reveals about your [category] journey."

    2. Then provide all 10 cards in THIS EXACT FORMAT:

    NUMBER. POSITION — CARD NAME
    Description of the card's meaning in this position (2-3 sentences).

    EXAMPLE FORMAT (but choose your own cards):

    1. Present — [Card You Choose]
    [Your interpretation here]

    2. Challenge — [Card You Choose]
    [Your interpretation here]

    [Continue for all 10 positions...]

    ═══════════════════════════════════════════════════════════════════
    THE 10 CELTIC CROSS POSITIONS (in order):
    ═══════════════════════════════════════════════════════════════════

    1. Present — Current situation
    2. Challenge — Immediate obstacle or crossing influence
    3. Past — Recent past that led to this moment
    4. Future — What's approaching in the near future
    5. Conscious — Conscious thoughts and goals
    6. Unconscious — Hidden influences and subconscious
    7. Attitude — Your approach and self-perception
    8. External Factors — Environment and others' influence
    9. Hope and Fears — Inner emotions and anxieties
    10. Outcome — Likely outcome if current path continues

    ═══════════════════════════════════════════════════════════════════
    CARD NAMING RULES - USE EXACT NAMES:
    ═══════════════════════════════════════════════════════════════════

    MAJOR ARCANA (22 cards - include "The" where appropriate):
    The Fool, The Magician, The High Priestess, The Empress, The Emperor,
    The Hierophant, The Lovers, The Chariot, Strength, The Hermit,
    Wheel of Fortune, Justice, The Hanged Man, Death, Temperance,
    The Devil, The Tower, The Star, The Moon, The Sun, Judgement, The World

    MINOR ARCANA FORMAT:
    - Structure: "[Rank] of [Suit]"
    - Ranks: Ace, Two, Three, Four, Five, Six, Seven, Eight, Nine, Ten,
             Page, Knight, Queen, King
    - Suits: Cups, Wands, Swords, Pentacles

    Examples: "Two of Cups", "King of Swords", "Ace of Wands", "Ten of Pentacles"

    ═══════════════════════════════════════════════════════════════════
    CRITICAL FORMAT RULES:
    ═══════════════════════════════════════════════════════════════════

    ✓ Each card must start: NUMBER. POSITION — CARD NAME
    ✓ Use NUMBER followed by period: "1. " "2. " etc.
    ✓ Use em dash (—) between position and card name
    ✓ Card description: 2-3 sentences, conversational tone
    ✓ NO asterisks, NO hashtags, NO bold formatting
    ✓ Each card on its own line
    ✓ One blank line between cards

    ═══════════════════════════════════════════════════════════════════
    IMPORTANT REMINDERS:
    ═══════════════════════════════════════════════════════════════════

    - Choose cards intuitively based on the person's profile
    - Each reading should be unique and personalized
    - Consider their birth date, location, and category (#{@reading.category_tarot})
    - Provide meaningful, specific guidance
    - Balance honesty with compassion
    - All 10 cards must be different from each other

    Generate the complete Celtic Cross reading now.
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
