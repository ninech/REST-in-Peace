require 'rest_in_peace'
require 'rest_in_peace/active_model_api'
require 'ostruct'

describe RESTinPeace do
  let(:api_double) { double('IamAnAPI') }
  let(:response) { OpenStruct.new(body: 'string!') }
  let(:extended_class) do
    Class.new do
      include RESTinPeace

      rest_in_peace do
        attributes do
          read :id, :name
          write :description, :title
        end

        resource do
          put :save, '/class/:id'
          post :create, '/class'
        end

        acts_as_active_model
      end
    end
  end

  let(:id) { 1 }
  let(:name) { 'pony one' }
  let(:description) { nil }
  let(:attributes) do
    {
      id: id,
      name: name,
      description: description,
    }
  end
  let(:instance) { extended_class.new(attributes) }

  context 'class methods' do
    describe '::acts_as_active_model' do
      context 'missing save method' do
        let(:extended_class) do
          Class.new do
            include RESTinPeace
            rest_in_peace do
              acts_as_active_model
            end
          end
        end

        it 'raises an error when no save method specified' do
          expect { extended_class.new }.to raise_error(RESTinPeace::ActiveModelAPI::MissingSaveMethod)
        end
      end

      context 'missing create method' do
        let(:extended_class) do
          Class.new do
            include RESTinPeace
            rest_in_peace do
              resource do
                put :save, '/yolo'
              end
              acts_as_active_model
            end
          end
        end

        it 'raises an error when no create method specified' do
          expect { extended_class.new }.to raise_error(RESTinPeace::ActiveModelAPI::MissingSaveMethod)
        end
      end
    end

    describe '#model_name' do
      before do
        def extended_class.model_name
          ActiveModel::Name.new(self, nil, 'TemporaryClassForTests')
        end
      end
      specify { expect(extended_class.model_name).to eq('TemporaryClassForTests') }
      specify { expect(extended_class.model_name).to respond_to(:route_key) }
    end
  end

  context 'instance methods' do
    before do
      extended_class.api = api_double
      allow(api_double).to receive(:put).and_return(response)
    end

    describe '#changed?' do
      context 'a new instance' do
        specify { expect(instance.changed?).to eq(false) }
      end

      context 'a modified instance' do
        before do
          instance.description = 'new value'
        end
        specify { expect(instance.changed?).to eq(true) }
      end

      context 'a saved instance' do
        before do
          instance.description = 'new value'
          instance.save
        end
        specify { expect(instance.changed?).to eq(false) }
      end
    end

    describe 'attribute methods' do
      specify { expect(instance).to respond_to(:description_changed?) }
      specify { expect(instance).to respond_to(:title_changed?) }
    end
  end
end
