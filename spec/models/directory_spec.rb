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
    subject { described_class.new(name: 'Folder A', directory_id: nil) }

    it 'is valid with valid attributes' do
      expect(subject).to be_valid
    end

    it 'is not valid without a name' do
      subject.name = nil
      expect(subject).not_to be_valid
      expect(subject.errors[:name]).to include("can't be blank")
    end

    context 'uniqueness validation' do
      before do
        described_class.create!(name: 'Folder A', directory_id: nil)
      end

      it 'is not valid with duplicate name in the same directory' do
        duplicate = described_class.new(name: 'Folder A', directory_id: nil)
        expect(duplicate).not_to be_valid
        expect(duplicate.errors[:name]).to include('has already been taken')
      end

      it 'is valid with same name in different directories' do
        parent_dir = described_class.create!(name: 'Parent Folder', directory_id: nil)
        new_dir = described_class.new(name: 'Folder A', directory_id: parent_dir.id)
        expect(new_dir).to be_valid
      end
    end
  end

  describe '#full_path' do
    let(:root_dir) { described_class.create!(name: 'root') }
    let(:child_dir) { described_class.create!(name: 'child', directory_id: root_dir.id) }
    let(:grandchild_dir) { described_class.create!(name: 'grandchild', directory_id: child_dir.id) }

    it 'returns name if no parent' do
      expect(root_dir.full_path).to eq('root')
    end

    it 'returns full path concatenated with parent names' do
      expect(child_dir.full_path).to eq('root/child')
      expect(grandchild_dir.full_path).to eq('root/child/grandchild')
    end
  end
end
