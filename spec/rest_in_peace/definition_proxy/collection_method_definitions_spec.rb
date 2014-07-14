require 'rest_in_peace'
require 'rest_in_peace/definition_proxy/collection_method_definitions'

describe RESTinPeace::DefinitionProxy::CollectionMethodDefinitions do
  let(:method_name) { :find }
  let(:url_template) { '/a/:id' }
  let(:default_params) { {} }
  let(:struct) { Struct.new(:id, :name) }
  let(:target) do
    Class.new(struct) do
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

    describe 'the created method' do
      before do
        allow(api_call_double).to receive(:get)
      end

      context 'without a paginator' do
        it 'does not extend api call' do
          expect(api_call_double).to_not receive(:extend)

          subject.get(:find, '/a/:id', default_params)
          target.find(1)
        end
      end

      context 'with a paginator' do
        it 'extends api call' do
          expect(api_call_double).to receive(:extend)

          subject.get(:find, '/a/:id', default_params.merge(paginate_with: Module))
          target.find(1)
        end
      end

      describe 'parameter and arguments handling' do
        it 'converts the parameters' do
          expect(RESTinPeace::ApiCall).to receive(:new).
            with(target.api, '/a/:id', target, {id: 1}).
            and_return(api_call_double)

          subject.get(:find, '/a/:id', default_params)
          target.find(1)
        end

        it 'appends the given attributes' do
          expect(RESTinPeace::ApiCall).to receive(:new).
            with(target.api, '/a', target, {name: 'daniele', last_name: 'in der o'}).
            and_return(api_call_double)

          subject.get(:all, '/a', {last_name: 'in der o'})
          target.all(name: 'daniele')
        end

        it 'does not modify the default params' do
          default_params = { per_page: 250 }
          subject.get(:find, '/a/:id', default_params)
          target.find(1)
          expect(default_params).to eq({ per_page: 250 })
        end
      end
    end
  end
end
