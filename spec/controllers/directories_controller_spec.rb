require 'rails_helper'

RSpec.describe 'DirectoriesController', type: :request do
  let!(:parent_directory) { create(:directory, name: 'Parent') }
  let!(:directory) { create(:directory, name: 'Child', directory_id: parent_directory.id) }

  describe 'GET /directories' do
    it 'returns a list of directories' do
      get directories_path

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body).to be_an(Array)
      expect(body.first['name']).to eq('Parent').or eq('Child')
    end
  end

  describe 'GET /directories/:id' do
    it 'returns the specified directory' do
      get directory_path(directory.id)

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body['name']).to eq('Child')
      expect(body['parent_id']).to eq(parent_directory.id)
    end
  end

  describe 'POST /directories' do
    it 'creates a new directory' do
      post directories_path, params: {
        directory: {
          name: 'New Folder',
          directory_id: parent_directory.id
        }
      }

      expect(response).to have_http_status(:created)
      body = JSON.parse(response.body)
      expect(body['name']).to eq('New Folder')
      expect(body['parent_id']).to eq(parent_directory.id)
    end

    it 'returns an error if required params are missing' do
      post directories_path, params: { directory: { name: '' } }

      expect(response).to have_http_status(:unprocessable_entity)
      body = JSON.parse(response.body)
      expect(body).to include('name')
    end
  end

  describe 'PATCH /directories/:id' do
    it 'updates an existing directory' do
      patch directory_path(directory.id), params: {
        directory: { name: 'Updated Name' }
      }

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body['name']).to eq('Updated Name')
    end

    it 'returns an error if update is invalid' do
      patch directory_path(directory.id), params: { directory: { name: '' } }

      expect(response).to have_http_status(:unprocessable_entity)
      body = JSON.parse(response.body)
      expect(body).to include('name')
    end
  end

  describe 'DELETE /directories/:id' do
    it 'deletes the directory' do
      delete directory_path(directory.id)

      expect(response).to have_http_status(:no_content)
      expect(Directory.find_by(id: directory.id)).to be_nil
    end
  end
end
