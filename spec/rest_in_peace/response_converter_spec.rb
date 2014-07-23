require 'rest_in_peace/response_converter'
require 'ostruct'

describe RESTinPeace::ResponseConverter do
  let(:element1) { { name: 'test1' } }
  let(:element2) { { name: 'test2' } }
  let(:response) { OpenStruct.new(body: response_body) }
  let(:converter) { RESTinPeace::ResponseConverter.new(response, klass) }

  describe '#result' do
    subject { converter.result }

    shared_examples_for 'an array input' do
      let(:response_body) { [element1, element2] }
      specify { expect(subject).to be_instance_of(Array) }
      specify { expect(subject).to eq([OpenStruct.new(name: 'test1'), OpenStruct.new(name: 'test2')]) }
    end

    shared_examples_for 'a hash input' do
      let(:response_body) { element1 }
      specify { expect(subject).to be_instance_of(OpenStruct) }
      specify { expect(subject).to eq(OpenStruct.new(name: 'test1')) }
    end

    shared_examples_for 'a string input' do
      let(:response_body) { 'yolo binary stuff' }
      specify { expect(subject).to be_instance_of(String) }
      specify { expect(subject).to eq('yolo binary stuff') }
    end

    context 'given type is a class' do
      let(:klass) { OpenStruct }
      context 'input is an array' do
        it_behaves_like 'an array input'
      end

      context 'input is a hash' do
        it_behaves_like 'a hash input'
      end

      context 'input is a string' do
        it_behaves_like 'a string input'
      end
    end

    context 'given type is an instance' do
      let(:klass) { OpenStruct.new }
      context 'input is an array' do
        it_behaves_like 'an array input'
      end

      context 'input is a hash' do
        it_behaves_like 'a hash input'
      end

      context 'input is a string' do
        it_behaves_like 'a string input'
      end
    end
  end
end
