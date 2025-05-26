FactoryBot.define do
  factory :directory do
    name { "Sample Directory" }
    directory_id { nil }  # parent directory (optional)
  end
end