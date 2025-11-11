// app/javascript/controllers/clipboard_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["source"] // Defines a target named 'source'

  copy(event) {
    event.preventDefault() // Prevents default link behavior if using an anchor tag
    navigator.clipboard.writeText(this.sourceTarget.value || this.sourceTarget.textContent)
      .then(() => {
        // Optional: Add visual feedback, e.g., change button text to "Copied!"
        console.log("Text copied to clipboard!");
      })
      .catch(err => {
        console.error("Failed to copy text: ", err);
      });
  }
}

