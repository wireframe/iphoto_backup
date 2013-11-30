require 'spec_helper'

describe IphotoBackup::CLI do
  TMP_OUTPUT_DIRECTORY = 'tmp/backup'
  let(:args) { [] }
  let(:options) {
    {
      config: 'spec/fixtures/AlbumData.xml',
      output: TMP_OUTPUT_DIRECTORY,
      filter: '.*'
    }
  }
  let(:config) do
    {
      pretend: true
    }
  end
  let(:cli) { IphotoBackup::CLI.new(args, options, config) }

  after do
    FileUtils.rm_rf TMP_OUTPUT_DIRECTORY
  end

  describe '#export' do
    before do
      cli.export
    end
    context 'with basic options' do
      it 'creates folder for first event' do
        expect(File.exists?('tmp/backup/2013-06-06 Summer Party')).to be_true
      end
      it 'creates folder for second event' do
        expect(File.exists?('tmp/backup/2013-10-10 Fall Supper')).to be_true
      end
      it 'copies images for first event' do
        expect(Dir.glob('tmp/backup/2013-06-06 Summer Party/*.jpg').length).to eq 2
      end
      it 'copies images for second event' do
        expect(Dir.glob('tmp/backup/2013-10-10 Fall Supper/*.jpg').length).to eq 2
      end
    end
    context 'when filter only matches first event' do
      let(:options) {
        {
          config: 'spec/fixtures/AlbumData.xml',
          output: TMP_OUTPUT_DIRECTORY,
          filter: 'Summer'
        }
      }
      it 'creates folder for first event' do
        expect(File.exists?('tmp/backup/2013-06-06 Summer Party')).to be_true
      end
      it 'does not createfolder for second event' do
        expect(File.exists?('tmp/backup/2013-10-10 Fall Supper')).to be_false
      end
    end
  end
end
