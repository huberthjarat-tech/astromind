module ReadingsHelper
  # ============================================
  # MAPEO DE CARTAS DEL TAROT
  # ============================================

  MAJOR_ARCANA_MAP = {
    "The Fool" => "00-TheFool",
    "The Magician" => "01-TheMagician",
    "The High Priestess" => "02-TheHighPriestess",
    "The Empress" => "03-TheEmpress",
    "The Emperor" => "04-TheEmperor",
    "The Hierophant" => "05-TheHierophant",
    "The Lovers" => "06-TheLovers",
    "The Chariot" => "07-TheChariot",
    "Strength" => "08-Strength",
    "The Hermit" => "09-TheHermit",
    "Wheel of Fortune" => "10-WheelOfFortune",
    "Justice" => "11-Justice",
    "The Hanged Man" => "12-TheHangedMan",
    "Death" => "13-Death",
    "Temperance" => "14-Temperance",
    "The Devil" => "15-TheDevil",
    "The Tower" => "16-TheTower",
    "The Star" => "17-TheStar",
    "The Moon" => "18-TheMoon",
    "The Sun" => "19-TheSun",
    "Judgement" => "20-Judgement",
    "The World" => "21-TheWorld"
  }.freeze

  RANKS_MAP = {
    "Ace" => "01",
    "Two" => "02",
    "Three" => "03",
    "Four" => "04",
    "Five" => "05",
    "Six" => "06",
    "Seven" => "07",
    "Eight" => "08",
    "Nine" => "09",
    "Ten" => "10",
    "Page" => "11",
    "Knight" => "12",
    "Queen" => "13",
    "King" => "14"
  }.freeze

  # ============================================
  # FORMATEAR LECTURA DE TAROT
  # ============================================

  def format_tarot_reading(content)
    return "" if content.blank?

    # Limpiar contenido
    content = content.gsub(/^---\s*$/, '')
    content = content.gsub(/\*\*/, '')  # Eliminar asteriscos
    content = content.gsub(/###/, '')   # Eliminar hashtags

    lines = content.split("\n")
    formatted_html = []
    current_card = nil
    card_content = []

    lines.each do |line|
      line = line.strip
      next if line.empty?

      # Detectar línea con número de carta
      # Acepta: "1. Present — The Empress" o "1. The Present Situation – The Lovers"
      if line.match?(/^\d+\.\s+(.+?)\s*[—–-]\s*(.+)$/)
        # Cerrar carta anterior si existe
        if current_card
          formatted_html << "<div class='tarot-card-content'>"
          formatted_html << card_content.map { |l| "<p>#{l}</p>" }.join
          formatted_html << "</div></div>"
          card_content = []
        end

        # Extraer información
        match = line.match(/^(\d+)\.\s+(.+?)\s*[—–-]\s*(.+)$/)
        number = match[1]
        position = match[2].strip
        card_name = match[3].strip

        # Iniciar nueva sección
        formatted_html << "<div class='tarot-card-section' data-card-name='#{card_name}'>"
        formatted_html << "  <div class='tarot-card-header'>"
        formatted_html << "    <div class='tarot-card-number'>#{number}</div>"
        formatted_html << "    <div class='tarot-card-title'>#{position} — #{card_name}</div>"
        formatted_html << "  </div>"

        current_card = card_name
      else
        # Es contenido de la carta
        card_content << line if line.present?
      end
    end

    # Cerrar última carta si existe
    if current_card && card_content.any?
      formatted_html << "<div class='tarot-card-content'>"
      formatted_html << card_content.map { |l| "<p>#{l}</p>" }.join
      formatted_html << "</div></div>"
    end

    sanitize(formatted_html.join("\n"),
      tags: %w[div h3 p strong em br span],
      attributes: %w[class data-card-name]
    )
  end

  # ============================================
  # EXTRAER CARTAS DE LA LECTURA
  # ============================================

def extract_tarot_cards(content)
  return [] if content.blank?

  cards = []

  # Normalizar el contenido primero
  normalized_content = content.gsub("\r\n", "\n").gsub("\r", "\n")

  # Buscar todas las líneas que empiezan con: "1. ", "2. ", etc.
  # Usando multiline mode (m) y capturando el nombre de la carta
  normalized_content.scan(/(?:^|\n)(\d+)\.\s*(.+?)\s*[—–-]\s*([^\n]+)/m).each do |match|
    number = match[0]
    position = match[1].strip
    card_name = match[2].strip

    # Limpiar el nombre de la carta (solo la primera línea si hay múltiples)
    card_name = card_name.split("\n").first.strip

    # Convertir a filename
    filename = card_name_to_filename(card_name)

    if filename
      cards << { filename: filename, display_name: card_name }
      Rails.logger.info "✅ Card #{number} extracted: #{card_name} → #{filename}" if Rails.env.development?
    else
      Rails.logger.warn "⚠️ Card #{number} not mapped: #{card_name}" if Rails.env.development?
    end
  end

  Rails.logger.info "📊 Total cards extracted: #{cards.length}" if Rails.env.development?

  cards
end

  # ============================================
  # CONVERTIR NOMBRE DE CARTA A ARCHIVO
  # ============================================

  def card_name_to_filename(card_name)
    return nil if card_name.blank?

    card_name = card_name.strip

    # Major Arcana
    return MAJOR_ARCANA_MAP[card_name] if MAJOR_ARCANA_MAP.key?(card_name)

    # Minor Arcana (e.g., "Two of Cups", "King of Swords")
    if card_name.match(/^(Ace|Two|Three|Four|Five|Six|Seven|Eight|Nine|Ten|Page|Knight|Queen|King)\s+of\s+(Cups|Wands|Swords|Pentacles)$/i)
      rank = $1
      suit = $2.capitalize

      number = RANKS_MAP[rank]
      return "#{suit}#{number}" if number
    end

    # Fallback
    nil
  end

  # ============================================
  # CONVERTIR ARCHIVO A NOMBRE PARA MOSTRAR
  # ============================================

  def filename_to_display_name(filename)
    return nil unless filename

    # Major Arcana (e.g., "00-TheFool" → "The Fool")
    if filename.match(/^(\d{2})-(.+)$/)
      name = $2.gsub(/([A-Z])/, ' \1').strip
      return name
    end

    # Minor Arcana (e.g., "Cups02" → "Two of Cups")
    if filename.match(/^(Cups|Wands|Swords|Pentacles)(\d{2})$/)
      suit = $1
      number = $2

      rank_name = RANKS_MAP.key(number)
      return "#{rank_name} of #{suit}" if rank_name
    end

    filename
  end
end
