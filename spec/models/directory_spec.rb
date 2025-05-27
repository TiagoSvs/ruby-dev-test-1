# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Directory, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:parent).class_name('Directory').optional }
    it { is_expected.to have_many(:subdirectories).class_name('Directory').dependent(:destroy) }

    it 'has many attached files' do
      expect(subject).to respond_to(:files)
    end
  end

  describe 'validations' do
    subject { build(:directory, name: 'Folder A', directory_id: nil) }

    it { is_expected.to validate_presence_of(:name) }

    it 'is valid with valid attributes' do
      expect(subject).to be_valid
    end

    it 'is not valid without a name' do
      subject.name = nil
      expect(subject).not_to be_valid
      expect(subject.errors[:name]).to include("can't be blank")
    end

    context 'uniqueness validation within scope of directory_id' do
      let!(:existing) { create(:directory, name: 'Folder A', directory_id: nil) }

      it 'is not valid with duplicate name in the same parent directory' do
        duplicate = build(:directory, name: 'Folder A', directory_id: nil)
        expect(duplicate).not_to be_valid
        expect(duplicate.errors[:name]).to include('has already been taken')
      end

      it 'is valid with the same name in a different parent directory' do
        parent_dir = create(:directory, name: 'Parent Folder')
        other = build(:directory, name: 'Folder A', directory_id: parent_dir.id)
        expect(other).to be_valid
      end
    end
  end

  describe '#full_path' do
    let!(:root_dir) { create(:directory, name: 'root') }
    let!(:child_dir) { create(:directory, name: 'child', directory_id: root_dir.id) }
    let!(:grandchild_dir) { create(:directory, name: 'grandchild', directory_id: child_dir.id) }

    it 'returns its own name if no parent' do
      expect(root_dir.full_path).to eq('root')
    end

    it 'returns full path including all parent directories' do
      expect(child_dir.full_path).to eq('root/child')
      expect(grandchild_dir.full_path).to eq('root/child/grandchild')
    end
  end
end
