# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'FilesController', type: :request do
  let(:directory) { create(:directory) }

  let(:file_blob) do
    ActiveStorage::Blob.create_and_upload!(
      io: StringIO.new('test file content'),
      filename: 'test.txt',
      content_type: 'text/plain'
    )
  end

  describe 'GET /directories/:directory_id/files' do
    it 'returns the files of the directory' do
      directory.files.attach(file_blob)

      get directory_files_path(directory.id)

      expect(response).to have_http_status(:ok)
      body = response.parsed_body

      expect(body).to be_an(Array)
      expect(body.first['filename']).to eq('test.txt')
      expect(body.first['full_path']).to include('test.txt')
    end
  end

  describe 'POST /directories/:directory_id/files' do
    it 'attaches files to the directory' do
      file = fixture_file_upload(Rails.root.join('spec/fixtures/files/test.txt'), 'text/plain')

      post directory_files_path(directory.id), params: { files: [file] }

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body['message']).to eq('Files uploaded successfully.')
      expect(directory.reload.files.count).to eq(1)
    end

    it 'returns an error if no file is provided' do
      post directory_files_path(directory.id), params: {}

      expect(response).to have_http_status(:bad_request)
      expect(response.parsed_body['error']).to eq('No files provided.')
    end
  end

  describe 'DELETE /directories/:directory_id/files/:id' do
    it 'removes the file from the directory' do
      directory.files.attach(file_blob)
      file = directory.files.last

      delete directory_file_path(directory.id, file.id)

      expect(response).to have_http_status(:no_content)
      expect(directory.reload.files).to be_empty
    end

    it 'returns an error if the file does not exist' do
      delete directory_file_path(directory.id, 'nonexistent-id')

      expect(response).to have_http_status(:not_found)
      expect(response.parsed_body['error']).to eq('File not found.')
    end
  end
end
