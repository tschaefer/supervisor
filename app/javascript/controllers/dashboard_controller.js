import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["selectedUuid"];

  connect() {
    document.addEventListener("turbo:load", this.restoreStack.bind(this));
  }

  select(event) {
    const uuid = event.currentTarget.dataset.uuid;
    this.selectedUuidTarget.value = uuid;
  }

  restoreStack() {
    const uuid = this.selectedUuidTarget.value;
    if (uuid) {
      this.updateStack(uuid);
    }
  }

  updateStack(uuid) {
    const stackFrame = document.getElementById("stack-frame");
    if (stackFrame) {
      this.currentUuidValue = uuid;
      Turbo.visit(`/dashboard?uuid=${uuid}`, { frame: stackFrame.id });
    }
  }
}

