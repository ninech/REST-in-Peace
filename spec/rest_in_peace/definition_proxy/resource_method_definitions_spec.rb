require 'rest_in_peace'
require 'rest_in_peace/definition_proxy/resource_method_definitions'

describe RESTinPeace::DefinitionProxy::ResourceMethodDefinitions do
  let(:target) do
    Class.new do
      include RESTinPeace
      rest_in_peace do
        attributes do
          read :id
          write :name
        end
      end

    end
  end
  let(:instance) { target.new }
  let(:definitions) { described_class.new(target) }
  let(:api_call_double) { object_double(RESTinPeace::ApiCall.new(target.api, '/a/:id', definitions, {})) }

  subject { definitions }

  before do
    allow(RESTinPeace::ApiCall).to receive(:new).and_return(api_call_double)
    allow(api_call_double).to receive(http_verb)
  end

  shared_examples_for 'an instance method' do
    it 'defines a singleton method on the target' do
      expect { subject.send(http_verb, method_name, url_template) }.
        to change { instance.respond_to?(method_name) }.from(false).to(true)
    end

    it 'adds the method to the registry' do
      subject.send(http_verb, method_name, url_template)
      expect(target.rip_registry[:resource]).to eq([method: http_verb, name: method_name, url: url_template])
    end
  end

  shared_examples_for 'an instance method with all attributes' do
    describe 'parameter and arguments handling' do
      it 'uses all the attributes of the class' do
        expect(RESTinPeace::ApiCall).to receive(:new).
          with(target.api, url_template, instance, instance.payload(false)).
          and_return(api_call_double)

        subject.send(http_verb, method_name, url_template)
        instance.send(method_name)
      end
    end
  end

  shared_examples_for 'an instance method with changed attributes' do
    describe 'parameter and arguments handling' do
      it 'uses the attributes of the class' do
        expect(RESTinPeace::ApiCall).to receive(:new).
          with(target.api, url_template, instance, instance.payload).
          and_return(api_call_double)

        subject.send(http_verb, method_name, url_template)
        instance.send(method_name)
      end
    end
  end

  shared_examples_for 'an instance method without attributes' do
    describe 'parameter and arguments handling' do
      it 'provides the id only' do
        expect(RESTinPeace::ApiCall).to receive(:new).
          with(target.api, url_template, instance, id: instance.id).
          and_return(api_call_double)

        subject.send(http_verb, method_name, url_template)
        instance.send(method_name)
      end
    end
  end

  context '#get' do
    it_behaves_like 'an instance method' do
      let(:http_verb) { :get }
      let(:method_name) { :reload }
      let(:url_template) { '/a/:id' }
    end

    describe 'the created method' do
      it_behaves_like 'an instance method with changed attributes' do
        let(:http_verb) { :get }
        let(:method_name) { :reload }
        let(:url_template) { '/a/:id' }
      end
    end
  end

  context '#patch' do
    it_behaves_like 'an instance method' do
      let(:http_verb) { :patch }
      let(:method_name) { :save }
      let(:url_template) { '/a/:id' }
    end

    describe 'the created method' do
      it_behaves_like 'an instance method with changed attributes' do
        let(:http_verb) { :patch }
        let(:method_name) { :save }
        let(:url_template) { '/a/:id' }
      end
    end
  end

  context '#post' do
    it_behaves_like 'an instance method' do
      let(:http_verb) { :post }
      let(:method_name) { :create }
      let(:url_template) { '/a/:id' }
    end

    describe 'the created method' do
      it_behaves_like 'an instance method with all attributes' do
        let(:http_verb) { :post }
        let(:method_name) { :create }
        let(:url_template) { '/a/:id' }
      end
    end
  end

  context '#put' do
    it_behaves_like 'an instance method' do
      let(:http_verb) { :put }
      let(:method_name) { :update }
      let(:url_template) { '/a/:id' }
    end

    describe 'the created method' do
      it_behaves_like 'an instance method with all attributes' do
        let(:http_verb) { :put }
        let(:method_name) { :update }
        let(:url_template) { '/a/:id' }
      end
    end
  end

  context '#delete' do
    it_behaves_like 'an instance method' do
      let(:http_verb) { :delete }
      let(:method_name) { :destroy }
      let(:url_template) { '/a/:id' }
    end

    describe 'the created method' do
      it_behaves_like 'an instance method without attributes' do
        let(:http_verb) { :delete }
        let(:method_name) { :destroy }
        let(:url_template) { '/a/:id' }
      end
    end
  end

end
