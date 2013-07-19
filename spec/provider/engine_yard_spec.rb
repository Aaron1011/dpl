require 'spec_helper'
require 'engineyard'
require 'engineyard-cloud-client'
require 'dpl/provider/engine_yard'

describe DPL::Provider::EngineYard do
  subject :provider do
    described_class.new(DummyContext.new, :app => 'example', :key_name => 'key', :api_key => "test")
  end

  describe :api do
    it 'accepts an api key' do
      api = stub(:api)
      provider.options.update(:api_key => 'test')
      ::EY::CloudClient.should_receive(:new).with(:token => 'test').and_return(api)
      provider.api.should be == api
    end

    it 'accepts a user and a password' do
      api = stub(:api)
      provider.options.update(:email => 'blah@foo.com', :password => 'bar', :api_key => nil)
      ::EY::CloudClient.should_receive(:authenticate).with('blah@foo.com', 'bar')
      ::EY::CloudClient.should_receive(:new).with(:token => nil).and_return(api)
      provider.api.should be == api
    end
  end

  context "with fake api" do
    let :api do
      stub "api",
        :current_user => stub(:email => 'blah@foo.com')
    end
    let :key do
      stub "key",
        :destroy => stub
    end

    before do
      ::EY::CloudClient.should_receive(:new).and_return(api)
      provider.api
    end

    its(:api) { should be == api }

    describe :check_auth do
      example do
        provider.should_receive(:log).with("authenticated as blah@foo.com")
        provider.check_auth
      end
    end

    describe :setup_key do
      example do
        File.should_receive(:read).with("the file").and_return("foo")
        ::EY::CloudClient::Keypair.should_receive(:create).with(api, {"name" => "key", "public_key" => "foo"})
        provider.setup_key("the file")
      end
    end

    describe :remove_key do
      example do
        api.should_receive(:delete)
        provider.remove_key
      end
    end
  end
end
