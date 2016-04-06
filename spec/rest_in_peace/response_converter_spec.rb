require 'rest_in_peace'
require 'rest_in_peace/response_converter'
require 'ostruct'

describe RESTinPeace::ResponseConverter do
  let(:element1) { { name: 'test1' } }
  let(:element2) { { name: 'test2' } }
  let(:response) { OpenStruct.new(body: response_body) }
  let(:converter) { RESTinPeace::ResponseConverter.new(response, klass) }
  let(:extended_class) do
    Class.new do
      include RESTinPeace
      rest_in_peace do
        attributes do
          read :name
        end
      end
    end
  end

  describe '#result' do
    subject { converter.result }

    shared_examples_for 'an array input' do
      let(:response_body) { [element1, element2] }
      specify { expect(subject).to be_instance_of(Array) }
      specify { expect(subject.first).to be_instance_of(extended_class) }
      specify { expect(subject.map(&:name)).to eq(%w(test1 test2)) }
      specify { expect(subject.first).to_not be_changed }
    end

    shared_examples_for 'a hash input' do
      let(:response_body) { element1 }
      specify { expect(subject).to be_instance_of(extended_class) }
      specify { expect(subject.name).to eq('test1') }
      it { is_expected.to_not be_changed }
    end

    shared_examples_for 'a string input' do
      let(:response_body) { 'yolo binary stuff' }
      specify { expect(subject).to be_instance_of(String) }
      specify { expect(subject).to eq('yolo binary stuff') }
    end

    shared_examples_for 'a nil object input' do
      let(:response_body) { nil }
      specify { expect(subject).to be_instance_of(NilClass) }
      specify { expect(subject).to eq(nil) }
    end

    shared_examples_for 'an unknown input do' do
      let(:response_body) { Object }
      specify { expect { subject }.to raise_error(RESTinPeace::ResponseConverter::UnknownConvertStrategy) }
    end

    context 'given type is a class' do
      let(:klass) { extended_class }
      context 'input is an array' do
        it_behaves_like 'an array input'
      end

      context 'input is a hash' do
        it_behaves_like 'a hash input'
      end

      context 'input is a string' do
        it_behaves_like 'a string input'
      end

      context 'input is a Nil object' do
        it_behaves_like 'a nil object input'
      end
    end

    context 'given type is an instance' do
      let(:klass) { extended_class.new }
      context 'input is an array' do
        it_behaves_like 'an array input'
      end

      context 'input is a hash' do
        it_behaves_like 'a hash input'
      end

      context 'input is a string' do
        it_behaves_like 'a string input'
      end

      context 'input is a Nil object' do
        it_behaves_like 'a nil object input'
      end
    end
  end
end
