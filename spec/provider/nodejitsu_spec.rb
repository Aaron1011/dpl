require 'spec_helper'
require 'dpl/provider/nodejitsu'

describe DPL::Provider::Nodejitsu do
  subject :provider do
    described_class.new(DummyContext.new, :username => 'foo', :api_key => 'blah')
  end

  describe config
end
