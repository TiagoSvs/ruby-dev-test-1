# frozen_string_literal: true

include Rails.application.routes.url_helpers

class FilesController < ApplicationController
  before_action :set_directory, only: %i[index create destroy]

  def index
    files = @directory.files.map { |file| serialize_file(file, @directory) }

    render json: files
  end

  def create
    if params[:files].blank?
      return render json: { error: I18n.t('messages.file.missing') }, status: :bad_request
    end

    @directory.files.attach(params[:files])
    render json: { message: I18n.t('messages.file.uploaded') }, status: :ok
  end

  def destroy
    file = @directory.files.find_by(id: params[:id])
    return render json: { error: I18n.t('messages.file.not_found') }, status: :not_found unless file

    file.purge
    head :no_content
  end

  private

  def set_directory
    @directory = Directory.find(params[:directory_id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: I18n.t('messages.directory.not_found') }, status: :not_found
  end

  def serialize_file(file, dir)
    {
      id: file.id,
      filename: file.filename.to_s,
      full_path: "#{dir.full_path}/#{file.filename}",
      url: rails_blob_path(file, only_path: true)
    }
  end
end
