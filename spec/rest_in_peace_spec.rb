require 'rest_in_peace'

describe RESTinPeace do

  let(:struct) { Struct.new(:name) }
  let(:extended_class) do
    Class.new(struct) do
      include RESTinPeace
    end
  end
  let(:attributes) { { name: 'test' } }
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

  describe '#api' do
    subject { instance }
    specify { expect(subject).to respond_to(:api).with(0).arguments }
  end

  describe '#to_h' do
    subject { instance }
    specify { expect(subject).to respond_to(:to_h).with(0).arguments }
  end

  describe '#initialize' do
    subject { instance }
    specify { expect(subject.name).to eq('test') }

    context 'unknown params' do
      let(:attributes) { { name: 'test42', email: 'yolo@example.org' } }
      specify { expect(subject.name).to eq('test42') }
      specify { expect { subject.email }.to raise_error(NoMethodError) }
    end
  end

end
