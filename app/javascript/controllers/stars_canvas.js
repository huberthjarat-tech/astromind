class StarsCanvas {
  constructor(canvasElement) {
    this.canvas = canvasElement;
    this.ctx = this.canvas.getContext('2d');
    this.stars = [];
    this.numStars = 200; // Número de estrellas
    this.animationId = null;

    this.init();
  }

  init() {
    // Configurar el tamaño del canvas
    this.resizeCanvas();

    // Crear las estrellas
    this.createStars();

    // Iniciar la animación
    this.animate();

    // Redimensionar cuando cambia el tamaño de la ventana
    window.addEventListener('resize', () => this.resizeCanvas());
  }

  resizeCanvas() {
    this.canvas.width = window.innerWidth;
    this.canvas.height = window.innerHeight;
  }

  createStars() {
    this.stars = [];

    for (let i = 0; i < this.numStars; i++) {
      this.stars.push({
        x: Math.random() * this.canvas.width,
        y: Math.random() * this.canvas.height,
        radius: Math.random() * 2, // Tamaño de la estrella (0-2px)
        vx: (Math.random() - 0.5) * 0.5, // Velocidad X
        vy: (Math.random() - 0.5) * 0.5, // Velocidad Y
        alpha: Math.random() * 0.8 + 0.2, // Opacidad (0.2 - 1.0)
        twinkleSpeed: Math.random() * 0.02 + 0.01 // Velocidad de parpadeo
      });
    }
  }

  drawStar(star) {
    this.ctx.beginPath();
    this.ctx.arc(star.x, star.y, star.radius, 0, Math.PI * 2);
    this.ctx.fillStyle = `rgba(255, 255, 255, ${star.alpha})`;
    this.ctx.fill();
    this.ctx.closePath();
  }

  updateStar(star) {
    // Mover la estrella
    star.x += star.vx;
    star.y += star.vy;

    // Si sale de la pantalla, reaparece del otro lado
    if (star.x < 0) star.x = this.canvas.width;
    if (star.x > this.canvas.width) star.x = 0;
    if (star.y < 0) star.y = this.canvas.height;
    if (star.y > this.canvas.height) star.y = 0;

    // Efecto de parpadeo (twinkle)
    star.alpha += star.twinkleSpeed;
    if (star.alpha > 1 || star.alpha < 0.2) {
      star.twinkleSpeed = -star.twinkleSpeed;
    }
  }

  animate() {
    // Limpiar el canvas con un fondo semi-transparente para efecto de estela
    this.ctx.fillStyle = 'rgba(10, 10, 30, 0.1)';
    this.ctx.fillRect(0, 0, this.canvas.width, this.canvas.height);

    // Actualizar y dibujar cada estrella
    this.stars.forEach(star => {
      this.updateStar(star);
      this.drawStar(star);
    });

    // Continuar la animación
    this.animationId = requestAnimationFrame(() => this.animate());
  }

  destroy() {
    if (this.animationId) {
      cancelAnimationFrame(this.animationId);
    }
    window.removeEventListener('resize', () => this.resizeCanvas());
  }
}

// Exportar para usar en Rails
export default StarsCanvas;

// Auto-inicializar cuando el DOM esté listo
document.addEventListener('DOMContentLoaded', () => {
  const canvas = document.getElementById('stars-canvas');
  if (canvas) {
    new StarsCanvas(canvas);
  }
});

// También inicializar cuando Turbo carga una página (para Rails 7)
document.addEventListener('turbo:load', () => {
  const canvas = document.getElementById('stars-canvas');
  if (canvas) {
    new StarsCanvas(canvas);
  }
});
