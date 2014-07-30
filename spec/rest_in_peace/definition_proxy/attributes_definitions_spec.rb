require 'rest_in_peace'
require 'rest_in_peace/definition_proxy/attributes_definitions'

describe RESTinPeace::DefinitionProxy::AttributesDefinitions do
  let(:target) do
    Class.new do
      include RESTinPeace
    end
  end
  let(:instance_of_target) { target.new }
  let(:definitions) { described_class.new(target) }

  subject { definitions }

  describe '#read' do
    it 'defines a getter for the given attributes' do
      expect { subject.read(:id) }.to change { instance_of_target.respond_to?(:id) }.from(false).to(true)
    end
    it 'does not define a setter for the given attributes' do
      expect { subject.read(:id) }.to_not change { instance_of_target.respond_to?(:id=) }.from(false)
    end
    specify { expect { subject.read(:id) }.to change { target.rip_attributes[:read] }.from([]).to([:id]) }
    specify { expect { subject.read(:id) }.to_not change { target.rip_attributes[:write] }.from([]) }
  end

  describe '#write' do
    it 'defines a getter for the given attributes' do
      expect { subject.write(:id) }.to change { instance_of_target.respond_to?(:id) }.from(false).to(true)
    end
    it 'defines a setter for the given attributes' do
      expect { subject.write(:id) }.to change { instance_of_target.respond_to?(:id=) }.from(false).to(true)
    end
    specify { expect { subject.write(:id) }.to change { target.rip_attributes[:read] }.from([]).to([:id]) }
    specify { expect { subject.write(:id) }.to change { target.rip_attributes[:write] }.from([]).to([:id]) }
  end
end
