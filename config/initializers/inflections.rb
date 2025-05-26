# frozen_string_literal: true

# myengine/config/initializers/inflections.rb
ActiveSupport::Inflector.inflections(:en) do |inflect|
  inflect.irregular 'directory', 'directories'
end
