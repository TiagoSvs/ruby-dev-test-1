# frozen_string_literal: true

class DirectoriesController < ApplicationController
  before_action :set_directory, only: %i[show update destroy]

  def index
    directories = Directory.page(params[:page]).per(params[:per_page] || 10)

    render json: {
      current_page: directories.current_page,
      total_pages: directories.total_pages,
      total_count: directories.total_count,
      directories: directories.map { |d| serialize_directory(d) }
    }
  end

  def show
    render json: serialize_directory(@directory)
  end

  def create
    directory = Directory.new(directory_params)

    if directory.save
      render json: serialize_directory(directory), status: :created
    else
      render json: directory.errors, status: :unprocessable_entity
    end
  end

  def update
    if @directory.update(directory_params)
      render json: serialize_directory(@directory)
    else
      render json: @directory.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @directory.destroy!
    head :no_content
  end

  private

  def set_directory
    @directory = Directory.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: I18n.t('messages.directory.not_found') }, status: :not_found
  end

  def directory_params
    params.expect(directory: %i[name directory_id])
  end

  def serialize_directory(directory)
    {
      directory_id: directory.id,
      name: directory.name,
      full_path: directory.full_path,
      parent_id: directory.directory_id,
      subdirectories: directory.subdirectories.map { |sub| { id: sub.id, name: sub.name } },
      files: directory.files.map { |file| { id: file.id, filename: file.filename.to_s } }
    }
  end
end
