require 'rest_in_peace'
require 'rest_in_peace/definition_proxy'
require 'ostruct'

describe RESTinPeace::DefinitionProxy do
  let(:resource_definitions) { object_double(RESTinPeace::DefinitionProxy::ResourceMethodDefinitions) }
  let(:collection_definitions) { object_double(RESTinPeace::DefinitionProxy::CollectionMethodDefinitions) }
  let(:attributes_definitions) { object_double(RESTinPeace::DefinitionProxy::AttributesDefinitions) }
  let(:target) { double('Target') }
  let(:proxy) { RESTinPeace::DefinitionProxy.new(target) }
  let(:test_proc) { ->() {} }

  subject { proxy }

  before do
    allow(RESTinPeace::DefinitionProxy::ResourceMethodDefinitions).
      to receive(:new).with(target).and_return(resource_definitions)
    allow(RESTinPeace::DefinitionProxy::CollectionMethodDefinitions).
      to receive(:new).with(target).and_return(collection_definitions)
    allow(RESTinPeace::DefinitionProxy::AttributesDefinitions).
      to receive(:new).with(target).and_return(attributes_definitions)
  end

  describe '#resource' do
    it 'forwards the given block to a resource method definition' do
      expect(resource_definitions).to receive(:instance_eval) do |&block|
        expect(block).to be_instance_of(Proc)
      end
      subject.resource(&test_proc)
    end
  end

  describe '#collection' do
    it 'forwards the given block to a collection method definition' do
      expect(collection_definitions).to receive(:instance_eval) do |&block|
        expect(block).to be_instance_of(Proc)
      end
      subject.collection(&test_proc)
    end
  end

  describe '#attributes' do
    it 'forwards the given block to a attributes method definition' do
      expect(attributes_definitions).to receive(:instance_eval) do |&block|
        expect(block).to be_instance_of(Proc)
      end
      subject.attributes(&test_proc)
    end
  end

  describe '#namespace_attributes_with' do
    let(:target) do
      Class.new do
        include RESTinPeace
      end
    end
    it 'configures the namespace' do
      expect { subject.namespace_attributes_with(:blubb) }.
        to change { target.rip_namespace }.from(nil).to(:blubb)
    end
  end

  describe '#acts_as_active_model' do
    it 'includes RESTinPeace::ActiveModelAPI' do
      expect(target).to receive(:include).with(RESTinPeace::ActiveModelAPI)
      subject.acts_as_active_model
    end
  end
end
