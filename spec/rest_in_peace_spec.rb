require 'rest_in_peace'

describe RESTinPeace do

  let(:extended_class) do
    Class.new do
      include RESTinPeace

      rest_in_peace do
        attributes do
          read :id, :name, :relation
          write :my_array, :my_hash, :array_with_hash, :overridden_attribute, :description
        end
      end

      def overridden_attribute
        'something else'
      end

      def relation=(v)
        @relation = v
      end

      def self_defined_method
        puts 'yolo'
      end
    end
  end
  let(:my_array) { %w(element) }
  let(:name) { 'test' }
  let(:my_hash) { { element1: 'yolo' } }
  let(:array_with_hash) { [my_hash.dup] }
  let(:overridden_attribute) { 'initial value' }
  let(:description) { 'old description' }
  let(:attributes) do
    {
      id: 1,
      name: name,
      relation: { id: 1234 },
      my_array: my_array,
      my_hash: my_hash,
      array_with_hash: array_with_hash,
      overridden_attribute: overridden_attribute,
      description: description,
    }
  end
  let(:instance) { extended_class.new(attributes) }

  describe '::api' do
    subject { extended_class }
    specify { expect(subject).to respond_to(:api).with(0).arguments }
  end

  describe '::rest_in_peace' do
    subject { extended_class }
    specify { expect(subject).to respond_to(:rest_in_peace).with(0).arguments }
    let(:definition_proxy) { object_double(RESTinPeace::DefinitionProxy) }


    it 'evaluates the given block inside the definition proxy' do
      allow(RESTinPeace::DefinitionProxy).to receive(:new).with(subject).and_return(definition_proxy)
      expect(definition_proxy).to receive(:instance_eval) do |&block|
        expect(block).to be_instance_of(Proc)
      end
      subject.rest_in_peace { }
    end
  end

  describe '::rip_registry' do
    subject { extended_class }
    specify { expect(extended_class).to respond_to(:rip_registry) }
    specify { expect(extended_class.rip_registry).to eq(collection: [], resource: []) }
  end

  describe '::rip_attributes' do
    subject { extended_class }
    specify { expect(extended_class).to respond_to(:rip_attributes) }
    specify do
      expect(extended_class.rip_attributes).to eq(
        read: [:id, :name, :relation, :my_array, :my_hash, :array_with_hash, :overridden_attribute, :description],
        write: [:my_array, :my_hash, :array_with_hash, :overridden_attribute, :description])
    end
  end

  describe '::rip_namespace' do
    subject { extended_class }
    specify { expect(subject).to respond_to(:rip_namespace) }
    specify { expect(subject).to respond_to(:rip_namespace=) }
    it 'allows setting the namespace' do
      expect { subject.rip_namespace = :blubb }.
        to change { subject.rip_namespace }.from(nil).to(:blubb)
    end
  end

  describe '#api' do
    subject { instance }
    specify { expect(subject).to respond_to(:api).with(0).arguments }
  end

  describe '#to_h' do
    subject { instance.to_h }
    specify { expect(subject).to eq(attributes.merge(overridden_attribute: 'something else')) }
  end

  describe '#payload' do
    subject { instance }
    specify { expect(subject).to respond_to(:payload).with(0).arguments }

    context 'without a namspace defined' do
      it 'adds id by default' do
        expect(subject.payload).to include(id: 1)
      end

      context 'overridden getter' do
        before do
          subject.overridden_attribute = 'new value'
        end
        specify { expect(subject.payload).to include(overridden_attribute: 'something else') }
      end

      context 'self defined methods' do
        specify { expect(subject).to respond_to(:self_defined_method) }
        specify { expect(subject.payload).to_not include(:self_defined_method) }
      end

      context 'hash' do
        before do
          subject.my_hash = { element1: 'swag' }
        end

        specify { expect(subject.payload[:my_hash]).to eq(element1: 'swag') }
      end

      context 'with objects assigned' do
        let(:new_hash) { double('OtherClass') }

        before do
          subject.my_hash = new_hash
        end

        it 'deeply calls payload' do
          expect(new_hash).to receive(:payload).and_return({})
          subject.payload
        end
      end
    end

    context 'with a namespace defined' do
      let(:extended_class) do
        Class.new do
          include RESTinPeace

          rest_in_peace do
            attributes do
              read :id
              write :name, :description
            end

            namespace_attributes_with :blubb
          end
        end
      end

      before do
        subject.name = 'new value'
      end

      specify { expect(subject.payload).to eq(id: 1, blubb: { id: 1, name: 'new value', description: 'old description' }) }
    end
  end

  describe '#initialize' do
    subject { instance }

    context 'read only attribute' do
      specify { expect { subject }.to_not raise_error }
      specify { expect(subject.name).to eq('test') }
    end

    context 'write attribute' do
      context 'via rip defined attribute' do
        it 'uses the setter' do
          expect_any_instance_of(extended_class).to receive(:my_array=)
          subject
        end
      end
      context 'self defined attribute' do
        it 'uses the setter' do
          expect_any_instance_of(extended_class).to receive(:relation=)
          subject
        end
      end
    end

    context 'unknown params' do
      let(:attributes) { { name: 'test42', email: 'yolo@example.org' } }
      specify { expect(subject.name).to eq('test42') }
      specify { expect { subject.email }.to raise_error(NoMethodError) }
    end

    context 'not given param' do
      let(:attributes) { {} }
      specify { expect(subject.name).to eq(nil) }
    end

    context 'read only param' do
      let(:attributes) { { id: 123 } }
      specify { expect(subject.id).to eq(123) }
    end
  end

  describe '#update_attributes' do
    let(:new_attributes) { { name: 'yoloswag', my_array: ['yoloswag'] } }
    subject { instance }
    specify do
      expect { subject.update_attributes(new_attributes) }.
        to change(instance, :my_array).from(attributes[:my_array]).to(new_attributes[:my_array])
    end

    specify do
      expect { subject.update_attributes(new_attributes) }.
        to_not change(instance, :name).from(attributes[:name])
    end
  end

  describe '#changed?' do
    subject { instance }

    context 'a new instance' do
      it { is_expected.to be_changed }
    end

    context 'a modified instance' do
      before do
        instance.description = 'new value'
      end
      it { is_expected.to be_changed }
    end

    context 'a saved instance' do
      before do
        instance.description = 'new value'
        instance.clear_changes
      end
      it { is_expected.to_not be_changed }
    end
  end
end
