import { Application } from "@hotwired/stimulus"

const application = Application.start()

// Configure Stimulus development experience
application.debug = false
window.Stimulus   = application

export { application }

// Manejo del overlay del navbar mobile
document.addEventListener('turbo:load', function() {
  const navbarToggler = document.querySelector('.navbar-toggler');
  const navbarCollapse = document.querySelector('.navbar-collapse');

  if (navbarToggler && navbarCollapse) {
    navbarToggler.addEventListener('click', function() {
      // Esperar a que Bootstrap termine la animación
      setTimeout(() => {
        if (navbarCollapse.classList.contains('show')) {
          document.body.classList.add('menu-open');
        } else {
          document.body.classList.remove('menu-open');
        }
      }, 50);
    });

    // Cerrar menú al hacer click en el overlay
    document.addEventListener('click', function(e) {
      if (document.body.classList.contains('menu-open')) {
        if (!navbarCollapse.contains(e.target) && !navbarToggler.contains(e.target)) {
          navbarToggler.click();
          document.body.classList.remove('menu-open');
        }
      }
    });

    // Cerrar menú al hacer click en un link
    const navLinks = navbarCollapse.querySelectorAll('.nav-link');
    navLinks.forEach(link => {
      link.addEventListener('click', function() {
        if (window.innerWidth <= 576) {
          navbarToggler.click();
          document.body.classList.remove('menu-open');
        }
      });
    });
  }
});
