# frozen_string_literal: true

Rails.application.routes.draw do
  mount Rswag::Api::Engine => '/api-docs'
  mount Rswag::Ui::Engine => '/api-docs'

  resources :directories do
    resources :files, only: %i[index create destroy]
  end
end
