require 'rest_in_peace'

describe RESTinPeace do

  let(:extended_class) do
    Class.new do
      include RESTinPeace

      rest_in_peace do
        attributes do
          read :id
          write :name, :my_array, :my_hash, :array_with_hash, :overridden_attribute
        end
      end

      def overridden_attribute
        'something else'
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
  let(:attributes) do
    {
      name: name,
      my_array: my_array,
      my_hash: my_hash,
      array_with_hash: array_with_hash,
      overridden_attribute: overridden_attribute,
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
        read: [:id, :name, :my_array, :my_hash, :array_with_hash, :overridden_attribute],
        write: [:name, :my_array, :my_hash, :array_with_hash, :overridden_attribute])
    end
  end

  describe '#api' do
    subject { instance }
    specify { expect(subject).to respond_to(:api).with(0).arguments }
  end

  describe '#hash_for_updates' do
    subject { instance }
    specify { expect(subject).to respond_to(:hash_for_updates).with(0).arguments }

    context 'overridden getter' do
      specify { expect(subject.hash_for_updates).to eq(attributes.merge(overridden_attribute: 'something else')) }
    end

    context 'self defined methods' do
      specify { expect(subject).to respond_to(:self_defined_method) }
      specify { expect(subject.hash_for_updates).to_not include(:self_defined_method) }
    end

    context 'hash' do
      specify { expect(subject.hash_for_updates[:my_hash]).to eq({ element1: 'yolo' }) }
    end

    context 'with objects assigned' do
      let(:my_hash) { double('OtherClass') }
      it 'deeply calls hash_for_updates' do
        expect(my_hash).to receive(:hash_for_updates).and_return({})
        subject.hash_for_updates
      end
    end
  end

  describe '#initialize' do
    subject { instance }
    specify { expect(subject.name).to eq('test') }

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
    let(:new_attributes) { { name: 'yoloswag' } }
    subject { instance }
    specify do
      expect { subject.update_attributes(new_attributes) }.
        to change(instance, :name).from(attributes[:name]).to(new_attributes[:name])
    end
  end
end
