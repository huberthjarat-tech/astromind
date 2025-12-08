module ReadingsHelper
  def format_tarot_reading(content)
    return "" if content.blank?

    # Limpiar contenido
    content = content.gsub(/^---\s*$/, '')
    content = content.gsub(/\*\*/, '') # Eliminar TODOS los **
    content = content.gsub(/###/, '')  # Eliminar TODOS los ###

    # Detectar líneas que empiezan con número + punto
    # Ejemplo: "1. The Present Situation – The Lovers"
    lines = content.split("\n")
    result = []
    current_card_content = []

    lines.each do |line|
      # Detectar si es un título de carta (empieza con número)
      if line =~ /^(\d+)\.\s*(.+)$/
        # Guardar contenido de la carta anterior
        if current_card_content.any?
          result << "<div class='tarot-card-content'>"
          result << current_card_content.map { |l| "<p>#{l}</p>" if l.strip.present? }.compact.join
          result << "</div>"
          current_card_content = []
        end

        # Crear nuevo header de carta
        number = $1
        title = $2.strip

        result << "<div class='tarot-card-section'>"
        result << "  <div class='tarot-card-header'>"
        result << "    <span class='tarot-card-number'>#{number}.</span>"
        result << "    <h3 class='tarot-card-title'>#{title}</h3>"
        result << "  </div>"
        result << "</div>"
      else
        # Es contenido normal, agregarlo al contenido actual
        current_card_content << line.strip if line.strip.present?
      end
    end

    # Cerrar el último contenido
    if current_card_content.any?
      result << "<div class='tarot-card-content'>"
      result << current_card_content.map { |l| "<p>#{l}</p>" if l.strip.present? }.compact.join
      result << "</div>"
    end

    sanitize(result.join("\n"),
      tags: %w[div h3 p strong em br span],
      attributes: %w[class]
    )
  end
end
