class Employee < ApplicationRecord
  TYPES = %w[employee domestic_employee worker]

  has_many :addresses, dependent: :destroy
  has_many :contacts, dependent: :destroy

  accepts_nested_attributes_for :addresses, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :contacts, allow_destroy: true, reject_if: :all_blank

  validates :name, presence: true, length: { minimum: 2 }
  validates :document, presence: true, uniqueness: true
  validates :salary, presence: true, numericality: { greater_than: 0 }
  validates :employee_type, presence: true

  enum :employee_type, {
    employee: 1,
    domestic_employee: 2,
    worker: 3
  }
end
