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
          expect { extended_class.new }.to raise_error(RESTinPeace::ActiveModelAPI::MissingMethod)
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
          expect { extended_class.new }.to raise_error(RESTinPeace::ActiveModelAPI::MissingMethod)
        end
      end
    end

    describe '::model_name' do
      before do
        def extended_class.model_name
          ActiveModel::Name.new(self, nil, 'TemporaryClassForTests')
        end
      end
      specify { expect(extended_class.model_name).to eq('TemporaryClassForTests') }
      specify { expect(extended_class.model_name).to respond_to(:route_key) }
    end

    describe 'validation handling' do
      specify { expect(extended_class).to respond_to(:human_attribute_name).with(2).arguments }
      specify { expect(extended_class.human_attribute_name(:description)).to eq('description') }

      specify { expect(extended_class).to respond_to(:lookup_ancestors).with(0).arguments }
      specify { expect(extended_class.lookup_ancestors).to eq([extended_class]) }
    end
  end

  context 'instance methods' do
    before do
      extended_class.api = api_double
      allow(api_double).to receive(:put).and_return(response)
      allow(api_double).to receive(:post).and_return(response)
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

    describe '#to_key' do
      specify { expect(instance.to_key).to eq([1]) }
    end

    describe '#persisted?' do
      context 'persisted model' do
        specify { expect(instance.persisted?).to eq(true) }
      end

      context 'not yet persisted model' do
        let(:id) { nil }
        specify { expect(instance.persisted?).to eq(false) }
      end
    end

    describe '#save' do
      context 'without errors' do
        let(:response) { OpenStruct.new(body: { name: 'new name from api' }) }

        specify { expect { instance.save }.to_not raise_error }
        specify { expect(instance.save.object_id).to eq(instance.object_id) }
        specify { expect { instance.save }.to change(instance, :name) }
      end

      context 'with errors' do
        before do
          instance.description = 'value!'
        end
        let(:response) { OpenStruct.new(body: { errors: { 'description' => ['is not empty'] } }) }

        specify { expect { instance.save }.to change { instance.errors.any? } }
        specify { expect { instance.save }.to_not change { instance.description } }
      end
    end

    describe '#create' do
      context 'without errors' do
        let(:response) { OpenStruct.new(body: { name: 'new name from api' }) }

        specify { expect { instance.create }.to_not raise_error }
        specify { expect(instance.create.object_id).to eq(instance.object_id) }
        specify { expect { instance.create }.to change(instance, :name) }
      end

      context 'with errors' do
        before do
          instance.description = 'value!'
        end
        let(:response) { OpenStruct.new(body: { errors: { 'description' => ['is not empty'] } }) }

        specify { expect { instance.create }.to change { instance.errors.any? } }
        specify { expect { instance.create }.to_not change { instance.description } }
      end
    end

    describe 'validation handling' do
      let(:description) { 'desc' }

      specify { expect(instance).to respond_to(:read_attribute_for_validation).with(1).argument }
      specify { expect(instance.read_attribute_for_validation(:description)).to eq('desc') }

      describe '#errors' do
        specify { expect(instance.errors).to be_instance_of(ActiveModel::Errors) }
      end

      describe '#errors=' do
        let(:errors) { { description: ['must not be empty'] } }
        specify { expect { instance.errors = errors }.to change { instance.errors.count } }
      end
    end
  end
end
