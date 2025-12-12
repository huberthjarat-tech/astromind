console.log('🎴 Tarot Carousel Script Loaded');

function initTarotCarousel() {
  console.log('🎴 Initializing Tarot Carousel...');

  const track = document.querySelector('.carousel-track');
  const cards = document.querySelectorAll('.carousel-card');
  const prevBtn = document.querySelector('.carousel-nav.prev');
  const nextBtn = document.querySelector('.carousel-nav.next');
  const indicators = document.querySelectorAll('.indicator');

  console.log('Found elements:', {
    track: !!track,
    cards: cards.length,
    prevBtn: !!prevBtn,
    nextBtn: !!nextBtn,
    indicators: indicators.length
  });

  if (!track || cards.length === 0) {
    console.error('❌ Carousel elements not found!');
    return;
  }

  let currentIndex = 0;
  const CARD_WIDTH = 280;
  const GAP = 32;

  function moveToCard(index) {
    console.log('Moving to card:', index);

    // Mover el track
    const offset = -(index * (CARD_WIDTH + GAP));
    track.style.transform = `translateX(${offset}px)`;

    // Actualizar active en cartas
    cards.forEach((card, i) => {
      card.classList.toggle('active', i === index);
    });

    // Actualizar active en indicadores
    indicators.forEach((indicator, i) => {
      indicator.classList.toggle('active', i === index);
    });

    // Actualizar botones
    prevBtn.disabled = (index === 0);
    nextBtn.disabled = (index === cards.length - 1);

    currentIndex = index;
  }

  // Click en botón anterior
  prevBtn.addEventListener('click', () => {
    console.log('⬅️ Previous clicked');
    if (currentIndex > 0) {
      moveToCard(currentIndex - 1);
    }
  });

  // Click en botón siguiente
  nextBtn.addEventListener('click', () => {
    console.log('➡️ Next clicked');
    if (currentIndex < cards.length - 1) {
      moveToCard(currentIndex + 1);
    }
  });

  // Click en indicadores
  indicators.forEach((indicator, index) => {
    indicator.addEventListener('click', () => {
      console.log('🔘 Indicator clicked:', index);
      moveToCard(index);
    });
  });

  // Inicializar
  moveToCard(0);
  console.log('✅ Carousel initialized successfully!');
}

// Ejecutar al cargar la página
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', initTarotCarousel);
} else {
  initTarotCarousel();
}

// Ejecutar también con Turbo
document.addEventListener('turbo:load', initTarotCarousel);
