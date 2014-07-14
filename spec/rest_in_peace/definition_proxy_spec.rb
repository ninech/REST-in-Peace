require 'rest_in_peace/definition_proxy'

describe RESTinPeace::DefinitionProxy do
  let(:resource_definitions) { double(RESTinPeace::DefinitionProxy::ResourceMethodDefinitions) }
  let(:collection_definitions) { double(RESTinPeace::DefinitionProxy::CollectionMethodDefinitions) }
  let(:target) { }
  let(:proxy) { RESTinPeace::DefinitionProxy.new(target) }
  let(:test_proc) { ->() {} }

  subject { proxy }

  before do
    allow(RESTinPeace::DefinitionProxy::ResourceMethodDefinitions).
      to receive(:new).with(target).and_return(resource_definitions)
    allow(RESTinPeace::DefinitionProxy::CollectionMethodDefinitions).
      to receive(:new).with(target).and_return(collection_definitions)
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
end
