require 'rest_in_peace/api_call'
require 'ostruct'

describe RESTinPeace::ApiCall do
  let(:api) { double }
  let(:url_template) { '/rip/:id' }
  let(:klass) { OpenStruct }
  let(:params) { {id: 1} }

  let(:api_call) { RESTinPeace::ApiCall.new(api, url_template, klass, params) }

  let(:response) { OpenStruct.new(body: []) }

  describe '#get' do
    context 'with enough parameters for the template' do
      it 'calls the api with the parameters' do
        expect(api).to receive(:get).with('/rip/1', {}).and_return(response)
        api_call.get
      end
    end

    context 'with more parameters than needed' do
      let(:params) { { id: 1, name: 'test' } }
      it 'uses also the additional parameters' do
        expect(api).to receive(:get).with('/rip/1', name: 'test').and_return(response)
        api_call.get
      end
    end
  end

  describe '#post' do
    let(:url_template) { '/rip' }
    let(:params) { { name: 'test' } }
    it 'calls the api with the parameters' do
      expect(api).to receive(:post).with('/rip', name: 'test').and_return(response)
      api_call.post
    end
  end

  describe '#patch' do
    let(:params) { { id: 1, name: 'test' } }
    it 'calls the api with the parameters' do
      expect(api).to receive(:patch).with('/rip/1', name: 'test').and_return(response)
      api_call.patch
    end
  end

  describe '#put' do
    let(:params) { { id: 1, name: 'test' } }
    it 'calls the api with the parameters' do
      expect(api).to receive(:put).with('/rip/1', name: 'test').and_return(response)
      api_call.put
    end
  end

  describe '#delete' do
    it 'calls the api with the parameters' do
      expect(api).to receive(:delete).with('/rip/1', {}).and_return(response)
      api_call.delete
    end
  end
end
