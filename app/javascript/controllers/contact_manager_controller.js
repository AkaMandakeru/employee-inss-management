import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["contactContainer", "addButton"]
  static values = { maxContacts: { type: Number, default: 3 } }

  connect() {
    console.log("Contact manager controller connected")
    this.updateAddButtonVisibility()
  }

  addContact() {
    if (this.getVisibleContactCount() < this.maxContactsValue) {
      // Find the last contact fieldset and clone it
      const lastContact = this.contactContainerTarget.querySelector('.contact-fieldset:last-of-type')
      if (lastContact) {
        const newContact = lastContact.cloneNode(true)

        // Clear the values in the new contact
        newContact.querySelectorAll('input, select').forEach(input => {
          if (input.type !== 'hidden') {
            input.value = ''
          }
          // Update the name attributes to use a new index
          const nameAttr = input.getAttribute('name')
          if (nameAttr && nameAttr.includes('[contacts_attributes]')) {
            const newIndex = this.getNextContactIndex()
            const newName = nameAttr.replace(/\[\d+\]/, `[${newIndex}]`)
            input.setAttribute('name', newName)
          }
        })

        // Show the new contact
        newContact.style.display = 'block'

        // Add remove button if not present
        if (!newContact.querySelector('.remove-contact-btn')) {
          const removeBtn = document.createElement('button')
          removeBtn.type = 'button'
          removeBtn.className = 'btn btn-outline-danger btn-sm remove-contact-btn'
          removeBtn.textContent = 'Remove'
          removeBtn.addEventListener('click', () => this.removeContact(newContact))

          const buttonContainer = newContact.querySelector('.contact-buttons')
          if (buttonContainer) {
            buttonContainer.appendChild(removeBtn)
          }
        }

        this.contactContainerTarget.appendChild(newContact)
        this.updateAddButtonVisibility()
      }
    }
  }

  removeContact(contactElement) {
    contactElement.remove()
    this.updateAddButtonVisibility()
  }

  getVisibleContactCount() {
    return this.contactContainerTarget.querySelectorAll('.contact-fieldset[style="display: block"], .contact-fieldset:not([style])').length
  }

  getNextContactIndex() {
    const existingContacts = this.contactContainerTarget.querySelectorAll('.contact-fieldset')
    return existingContacts.length
  }

  updateAddButtonVisibility() {
    const visibleCount = this.getVisibleContactCount()
    if (this.hasAddButtonTarget) {
      this.addButtonTarget.style.display = visibleCount < this.maxContactsValue ? 'block' : 'none'
    }
  }
}
