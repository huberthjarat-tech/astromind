import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button", "loading"]

  connect() {
    console.log("✅ Loading controller connected!")
    console.log("Button target:", this.hasButtonTarget)
    console.log("Loading target:", this.hasLoadingTarget)
  }

  show(event) {
    console.log("🚀 Show method called!")
    console.log("Event:", event)

    // Verificar que los targets existen
    if (!this.hasButtonTarget) {
      console.error("❌ Button target not found!")
      return
    }

    if (!this.hasLoadingTarget) {
      console.error("❌ Loading target not found!")
      return
    }

    console.log("Hiding button...")
    this.buttonTarget.classList.add("d-none")

    console.log("Showing loading message...")
    this.loadingTarget.classList.remove("d-none")

    console.log("✅ Loading state activated!")
  }
}
