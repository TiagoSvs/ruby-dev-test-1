# frozen_string_literal: true

Rails.logger.debug 'Seeding directories...'

root_directories = Array.new(5) do |i|
  Directory.create!(
    name: "Root Folder #{i + 1}"
  )
end

root_directories.each_with_index do |root_dir, index|
  2.times do |j|
    Directory.create!(
      name: "Subfolder #{index + 1}.#{j + 1}",
      directory_id: root_dir.id
    )
  end
end

Rails.logger.debug { "Created #{Directory.count} directories" }
