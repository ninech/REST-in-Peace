require 'rest_in_peace/template_sanitizer'
require 'ostruct'

describe RESTinPeace::TemplateSanitizer do
  let(:attributes) { {} }
  let(:template_sanitizer) { RESTinPeace::TemplateSanitizer.new(url_template, params, klass) }


  context 'with class' do
    let(:klass) { OpenStruct }

    describe '#url' do
      subject { template_sanitizer.url }

      context 'single token' do
        let(:params) { { id: 1 } }
        let(:url_template) { '/a/:id' }
        specify { expect(subject).to eq('/a/1') }
      end

      context 'multiple token' do
        let(:params) { { id: 2, a_id: 1 } }
        let(:url_template) { '/a/:a_id/b/:id' }
        specify { expect(subject).to eq('/a/1/b/2') }
      end

      context 'incomplete params' do
        let(:params) { { id: 1 } }
        let(:url_template) { '/a/:a_id/b/:id' }
        specify { expect { subject }.to raise_error(RESTinPeace::TemplateSanitizer::IncompleteParams) }
      end
    end

    describe '#tokens' do
      let(:params) { {} }

      context 'single token' do
        let(:url_template) { '/a/:id' }
        subject { template_sanitizer.tokens }
        specify { expect(subject).to eq(%w(id)) }
      end

      context 'multiple tokens' do
        let(:url_template) { '/a/:a_id/b/:id' }
        subject { template_sanitizer.tokens }
        specify { expect(subject).to eq(%w(a_id id)) }
      end
    end

    describe '#leftover_params' do
      let(:params) { { id: 1, name: 'test' } }
      let(:url_template) { '/a/:id' }
      subject { template_sanitizer.leftover_params }

      specify { expect(subject).to eq({name: 'test'}) }
    end
  end

  context 'with object' do
    let(:klass) { OpenStruct.new(attributes) }

    describe '#url' do
      subject { template_sanitizer.url }

      context 'single token' do
        let(:params) { { id: 1 } }
        let(:url_template) { '/a/:id' }
        specify { expect(subject).to eq('/a/1') }
      end

      context 'multiple token' do
        let(:params) { { id: 2, a_id: 1 } }
        let(:url_template) { '/a/:a_id/b/:id' }
        specify { expect(subject).to eq('/a/1/b/2') }
      end

      context 'tokens with substrings' do
        let(:params) { { element: 'asd', element_id: 1 } }
        let(:url_template) { '/a/:element/b/:element_id' }
        specify { expect(subject).to eq('/a/asd/b/1') }
      end

      context 'tokens with substrings, reverse order' do
        let(:params) { { element: 'asd', element_id: 1 } }
        let(:url_template) { '/a/:element_id/b/:element' }
        specify { expect(subject).to eq('/a/1/b/asd') }
      end

      context 'incomplete params' do
        let(:params) { {} }
        let(:url_template) { '/a/:id' }
        specify { expect { subject }.to raise_error(RESTinPeace::TemplateSanitizer::IncompleteParams) }
      end

      context 'immutability of the url template' do
        let(:params) { { id: 1 } }
        let(:url_template) { '/a/:id' }
        specify { expect { subject }.to_not change { url_template } }
      end

      context 'immutability of the params' do
        let(:params) { { id: 1 } }
        let(:url_template) { '/a/:id' }
        specify { expect { subject }.to_not change { params } }
      end

      context 'tokens from attributes' do
        let(:params) { { id: 1 } }
        let(:attributes) { { a_id: 2 } }
        let(:url_template) { '/a/:a_id/b/:id' }
        specify { expect(subject).to eq('/a/2/b/1') }
      end

      context 'incomplete params and attributes' do
        let(:params) { { id: 1 } }
        let(:attributes) { {} }
        let(:url_template) { '/a/:a_id/b/:id' }
        specify { expect { subject }.to raise_error(RESTinPeace::TemplateSanitizer::IncompleteParams) }
      end

      context 'param which need to be encoded' do
        let(:params) { { id: 'this param need to be encoded' } }
        let(:encoded_param) { 'this+param+need+to+be+encoded' }
        let(:attributes) { { a_id: 2 } }
        let(:url_template) { '/a/:a_id/b/:id' }
        specify { expect(subject).to eq("/a/2/b/#{encoded_param}") }
      end
    end

    describe '#tokens' do
      let(:params) { {} }

      context 'single token' do
        let(:url_template) { '/a/:id' }
        subject { template_sanitizer.tokens }
        specify { expect(subject).to eq(%w(id)) }
      end

      context 'multiple tokens' do
        let(:url_template) { '/a/:a_id/b/:id' }
        subject { template_sanitizer.tokens }
        specify { expect(subject).to eq(%w(a_id id)) }
      end
    end

    describe '#leftover_params' do
      let(:params) { { id: 1, name: 'test' } }
      let(:url_template) { '/a/:id' }
      subject { template_sanitizer.leftover_params }

      specify { expect(subject).to eq({name: 'test'}) }
    end

    describe '#encode_uri' do
      let(:params) { { id: 1, name: 'test' } }
      let(:url_template) { '/a/:id' }
      let(:raw_string) { 'it is a raw string@meta' }
      let(:encoded_string) { 'it+is+a+raw+string%40meta' }
      subject { template_sanitizer.encode_uri(raw_string) }

      specify { expect(subject).to eq encoded_string }
    end
  end
end
