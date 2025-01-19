import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["selectedUuid"];

  connect() {
    document.addEventListener("turbo:load", this.restoreLog.bind(this));
  }

  select(event) {
    const uuid = event.currentTarget.dataset.uuid;
    this.selectedUuidTarget.value = uuid;
  }

  restoreLog() {
    const uuid = this.selectedUuidTarget.value;
    if (uuid) {
      this.updateLogs(uuid);
    }
  }

  updateLogs(uuid) {
    const logFrame = document.getElementById("log-frame");
    if (logFrame) {
      this.currentUuidValue = uuid;
      Turbo.visit(`/dashboard?uuid=${uuid}`, { frame: logFrame.id });
    }
    const statisticsFrame = document.getElementById("statistics-frame");
    if (statisticsFrame) {
      this.currentUuidValue = uuid;
      Turbo.visit(`/dashboard?uuid=${uuid}`, { frame: statisticsFrame.id });
    }
  }
}

