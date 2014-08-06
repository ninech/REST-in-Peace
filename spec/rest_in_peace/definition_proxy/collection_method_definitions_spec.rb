require 'rest_in_peace'
require 'rest_in_peace/definition_proxy/collection_method_definitions'

describe RESTinPeace::DefinitionProxy::CollectionMethodDefinitions do
  let(:method_name) { :find }
  let(:url_template) { '/a/:id' }
  let(:default_params) { {} }
  let(:target) do
    Class.new do
      include RESTinPeace
    end
  end
  let(:definitions) { described_class.new(target) }
  let(:api_call_double) { object_double(RESTinPeace::ApiCall.new(target.api, url_template, definitions, default_params)) }

  subject { definitions }

  before do
    allow(RESTinPeace::ApiCall).to receive(:new).and_return(api_call_double)
  end

  context '#get' do
    it 'defines a singleton method on the target' do
      expect { subject.get(:find, '/a/:id', default_params) }.
        to change { target.respond_to?(:find) }.from(false).to(true)
    end

    it 'adds the method to the registry' do
      subject.get(:all, '/a')
      expect(target.rip_registry[:collection]).to eq([method: :get, name: :all, url: '/a'])
    end

    describe 'the created method' do
      before do
        allow(api_call_double).to receive(:get)
      end

      context 'without a paginator' do
        it 'does not extend api call' do
          expect(api_call_double).to_not receive(:extend)

          subject.get(:find, '/a/:id', default_params)
          target.find(id: 1)
        end
      end

      context 'with a paginator' do
        it 'extends api call' do
          expect(api_call_double).to receive(:extend)

          subject.get(:find, '/a/:id', default_params.merge(paginate_with: Module))
          target.find(id: 1)
        end
      end

      describe 'parameter and arguments handling' do
        context 'with given attributes' do
          it 'uses the given attributes' do
            expect(RESTinPeace::ApiCall).to receive(:new).
              with(target.api, '/a', target, {name: 'daniele', last_name: 'in der o'}).
              and_return(api_call_double)

            subject.get(:all, '/a', {last_name: 'in der o'})
            target.all(name: 'daniele')
          end

          it 'does not modify the default params' do
            default_params = { per_page: 250 }
            subject.get(:find, '/a/:id', default_params)
            target.find(id: 1)
            expect(default_params).to eq({ per_page: 250 })
          end

          it 'raises an error when param is not a hash' do
            subject.get(:find, '/a/:id', default_params)

            expect { target.find(1) }.to raise_error(RESTinPeace::DefinitionProxy::InvalidArgument)
          end
        end

        context 'without any attributes' do
          it 'uses the default params' do
            expect(RESTinPeace::ApiCall).to receive(:new).
              with(target.api, '/a', target, {last_name: 'in der o'}).
              and_return(api_call_double)

            subject.get(:all, '/a', {last_name: 'in der o'})
            target.all
          end
        end
      end
    end
  end
end
