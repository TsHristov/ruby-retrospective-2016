RSpec.describe 'Version' do
  def version(argument)
    version_obj.new(argument)
  end

  def error_message(string)
    "Invalid version string \'#{string}\'"
  end

  let(:version_obj) { Version }

  describe '.new' do
    context 'when no arguments are given' do
      it 'does not raise error if no arguments are given' do
        expect { Version.new }.not_to raise_error
      end
    end

    context 'when string is passed' do
      it 'raises ArgumentError for invalid input' do
        expect { version('1.') }
        .to raise_error(ArgumentError, error_message('1.'))
        expect { version('.3') }
        .to raise_error(ArgumentError, error_message('.3'))
        expect { version('0..3') }
        .to raise_error(ArgumentError, error_message('0..3'))
        expect { version('.3.') }
        .to raise_error(ArgumentError, error_message('.3.'))
        expect { version('.') }
        .to raise_error(ArgumentError, error_message('.'))
        expect { version('a.b.c') }
        .to raise_error(ArgumentError, error_message('a.b.c'))
        expect { version(version('321312..')) }
        .to raise_error(ArgumentError, error_message('321312..'))
      end
    end

    context 'when another version is passed' do
      it 'raises ArgumentError for invalid input' do
        expect { version(version('1.')) }
        .to raise_error(ArgumentError, error_message('1.'))
        expect { version(version('.3')) }
        .to raise_error(ArgumentError, error_message('.3'))
        expect { version(version('0..3')) }
        .to raise_error(ArgumentError, error_message('0..3'))
        expect { version(version('.3.')) }
        .to raise_error(ArgumentError, error_message('.3.'))
        expect { version(version('.')) }
        .to raise_error(ArgumentError, error_message('.'))
      end
    end
  end

  describe '#<=>' do
    it 'compares using ==' do
      expect(version('1.1.0')).to be == version('1.1')
      expect(version('1.1')).to be == version('1.1')
      expect(version('')).to  be == version('0')
      expect(version('1')).to be == version('1.0.0.0')
      expect(version('0')).to be == version('0.0.0.0')
    end

    it 'compares using >' do
      expect(version('1.2.3')).to be > version('1.2.2')
      expect(version('1.2.3')).to be > version('')
      expect(version('1.1')).to be > version('1')
      expect(version('1.0.1')).to be > version('1.0.0')
      expect(version('1.0.0')).to_not be > version('1.0.1')
    end

    it 'compares using <' do
      expect(version('1.2.3')).to be < version('1.3')
      expect(version('1.2.3')).to be < version('1.3.1')
      expect(version('1')).to be < version('1.1')
      expect(version('1.3.2')).to_not be < version('1.2')
    end

    it 'compares using >=' do
      expect(version('1.3.2')).to be >= version('1.3.2')
      expect(version('1.3.2')).to be >= version('1.3')
      expect(version('')).to_not be >= version('1')
    end

    it 'compares using <=' do
      expect(version('1')).to be <= version('1')
      expect(version('1.2')).to be <= version('1.3')
      expect(version('')).to be <= version('0')
      expect(version('1.0.1')).to_not be <= version('1.0.0')
    end
  end

  describe '#to_s' do
    it 'converts to string' do
      expect(version('1.1.0').to_s).to eq('1.1')
      expect(version('1.1').to_s).to eq('1.1')
      expect(version('').to_s).to eq('')
      expect(version('0').to_s).to eq('')
      expect(version(version('1.2.3')).to_s).to eq('1.2.3')
    end
  end

  describe '#components' do
    context 'when no optional parameter is given' do
      it 'breaks into components' do
        expect(version('1.3.5').components).to eq [1, 3, 5]
      end

      it 'excludes zeros at the end' do
        expect(version('1.3.5.0').components).to eq [1, 3, 5]
        expect(version('1.0.0.0').components).to eq [1]
      end

      it 'returns empty list for version 0' do
        expect(version('').components).to eq []
      end
    end

    context 'when optional parameter is given' do
      it 'breaks into N components' do
        expect(version('1.3.5').components(1)).to eq [1]
        expect(version('1.3.5').components(2)).to eq [1, 3]
        expect(version('1.3.5').components(3)).to eq [1, 3, 5]
        expect(version('1.3.5.0').components(3)).to eq [1, 3, 5]
        expect(version('1.3.5').components(4)).to eq [1, 3, 5, 0]
        expect(version('1.3.5').components(0)).to eq [1, 3, 5]
        expect(version('').components(4)).to eq [0, 0, 0, 0]
      end
    end

    it 'doesn`t modify the instance' do
      instance = version('1.2.3')
      instance.components.push 4
      expect(instance).to eq version('1.2.3')
    end
  end

  describe 'Version::Range' do
    describe '.new' do
      context 'when version is not valid' do
        it 'raises ArgumentError' do
          argument = '1.0.0.'
          expect { Version::Range.new(version(argument), version('2.0.0')) }
                .to raise_error(ArgumentError, error_message(argument))
          expect { Version::Range.new(version(''), version(argument)) }
                .to raise_error(ArgumentError, error_message(argument))
          expect { Version::Range.new(argument, '2.0.0') }
                .to raise_error(ArgumentError, error_message(argument))
        end
      end
    end

    describe '#include?' do
      context 'when an instance is passed' do
        it 'includes given version' do
          range = Version::Range.new(version('1'), version('2'))
          expect(range.include?(version('1.5'))).to be true
          expect(range.include?(version('1'))).to be true
          expect(range.include?(version('1.0.0'))).to be true
          expect(range.include?(version('2.1'))).to be false
          expect(range.include?(version(''))).to be false
          expect(range.include?(version('2'))).to be false
        end
      end

      context 'when a string is passed' do
        it 'includes given version' do
          first_version = version('1')
          second_version = version('2')
          range = Version::Range.new(first_version, second_version)
          expect(range.include?('1.5')).to be true
          expect(range.include?('1')).to be true
          expect(range.include?('1')).to be true
          expect(range.include?('1.0.0')).to be true
          expect(range.include?('2.1')).to be false
          expect(range.include?('')).to be false
          expect(range.include?('2')).to be false
        end
      end
    end

    describe '#to_a' do
      context 'when equal versions are passed' do
        it 'returns empty list' do
          range = Version::Range.new('1.1', '1.1')
          expect(range.to_a).to be_empty
        end
      end

      context 'when first version > second version' do
        it 'generates all versions between first and second version' do
          range = Version::Range.new('1.1.0', '1.1.2')
          expect(range.to_a).to eq ['1.1', '1.1.1']
          expect(range.to_a).to_not eq ['1.1', '1.1.1', '1.1.2']
          expect(range.to_a).to_not eq ['1.1.0', '1.1.1', '1.1.2']

          range = Version::Range.new(version('1.1.0'), version('1.2.2'))
          expect(range.to_a).to eq [
            '1.1', '1.1.1', '1.1.2', '1.1.3', '1.1.4', '1.1.5', '1.1.6', \
            '1.1.7', '1.1.8', '1.1.9', '1.2', '1.2.1'
          ]

          range = Version::Range.new('1.1', '1.2')
          expect(range.to_a).to eq [
            '1.1', '1.1.1', '1.1.2', '1.1.3', '1.1.4', '1.1.5', \
            '1.1.6', '1.1.7', '1.1.8', '1.1.9'
          ]

          range = Version::Range.new('', '')
          expect(range.to_a).to eq []
        end
      end
    end
  end
end
