require 'spec_helper'

describe IphotoBackup::CLI do
  let(:args) { [] }
  let(:options) { {} }
  let(:config) do
    {
      pretend: true
    }
  end
  let(:cli) { IphotoBackup::CLI.new(args, options, config) }

  describe '#export' do
    before do
      cli.export
    end
    it 'should run expected commands' do
      should meet_expectations
    end
  end


end
