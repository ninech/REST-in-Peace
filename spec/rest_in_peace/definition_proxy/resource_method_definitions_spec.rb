require 'rest_in_peace'
require 'rest_in_peace/definition_proxy/resource_method_definitions'

describe RESTinPeace::DefinitionProxy::ResourceMethodDefinitions do
  let(:struct) { Struct.new(:id, :name) }
  let(:target) do
    Class.new(struct) do
      include RESTinPeace
    end
  end
  let(:instance) { target.new }
  let(:definitions) { described_class.new(target) }
  let(:api_call_double) { object_double(RESTinPeace::ApiCall.new(target.api, '/a/:id', definitions, {})) }

  subject { definitions }

  before do
    allow(RESTinPeace::ApiCall).to receive(:new).and_return(api_call_double)
  end

  shared_examples_for 'an instance method' do
    it 'defines a singleton method on the target' do
      expect { subject.send(http_verb, method_name, url_template) }.
        to change { instance.respond_to?(method_name) }.from(false).to(true)
    end

    describe 'the created method' do
      before do
        allow(api_call_double).to receive(http_verb)
      end

      describe 'parameter and arguments handling' do
        it 'uses the attributes of the class' do
          expect(RESTinPeace::ApiCall).to receive(:new).
            with(target.api, url_template, instance, instance.to_h).
            and_return(api_call_double)

          subject.send(http_verb, method_name, url_template)
          instance.send(method_name)
        end
      end
    end
  end

  context '#get' do
    it_behaves_like 'an instance method' do
      let(:http_verb) { :get }
      let(:method_name) { :reload }
      let(:url_template) { '/a/:id' }
    end
  end

  context '#patch' do
    it_behaves_like 'an instance method' do
      let(:http_verb) { :patch }
      let(:method_name) { :save }
      let(:url_template) { '/a/:id' }
    end
  end

  context '#post' do
    it_behaves_like 'an instance method' do
      let(:http_verb) { :post }
      let(:method_name) { :create }
      let(:url_template) { '/a/:id' }
    end
  end

  context '#delete' do
    it_behaves_like 'an instance method' do
      let(:http_verb) { :delete }
      let(:method_name) { :destroy }
      let(:url_template) { '/a/:id' }
    end
  end

end
