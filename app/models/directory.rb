# frozen_string_literal: true

class Directory < ApplicationRecord
  belongs_to :parent, class_name: 'Directory', foreign_key: :directory_id, optional: true

  has_many :subdirectories, class_name: 'Directory', dependent: :destroy

  has_many_attached :files

  validates :name, presence: true, uniqueness: { scope: :directory_id }

  scope :root, -> { where(directory_id: nil) }

  def full_path
    parent ? "#{parent.full_path}/#{name}" : name
  end
end
