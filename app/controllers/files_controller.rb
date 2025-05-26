# frozen_string_literal: true

include Rails.application.routes.url_helpers

class FilesController < ApplicationController
  def index
    dir = Directory.find(params[:directory_id])
    files = dir.files.map { |file| serialize_file(file, dir) }

    render json: files
  end

  def create
    dir = Directory.find(params[:directory_id])

    if params[:files].blank?
      return render json: { error: 'No files provided.' },
                    status: :bad_request
    end

    dir.files.attach(params[:files])
    render json: { message: 'Files uploaded successfully.' }, status: :ok
  end

  def destroy
    folder = Directory.find(params[:directory_id])
    file = folder.files.find_by(id: params[:id])

    return render json: { error: 'File not found.' }, status: :not_found unless file

    file.purge
    head :no_content
  end

  private

  def serialize_file(file, dir)
    {
      id: file.id,
      filename: file.filename.to_s,
      full_path: "#{dir.full_path}/#{file.filename}",
      url: rails_blob_path(file, only_path: true)
    }
  end
end
