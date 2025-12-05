import { Controller } from "@hotwired/stimulus"

// Controls the loading message while AI generates the Tarot
export default class extends Controller {
  static targets = ["button", "loading"]

  show() {
    // Hide button
    this.buttonTarget.style.display = "none"

    // Show animated loading message
    this.loadingTarget.classList.remove("d-none")
  }
}
