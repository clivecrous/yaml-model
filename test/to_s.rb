require 'yaml-model'

describe YAML_Model, ".to_s" do

  AModel = Class.new( YAML_Model )

  before( :each ) do
    YAML_Model.reset!
  end

  it "Stringifies with the correct id" do
    next_oid = YAML_Model.next_oid
    AModel.create.to_s.should == "AModel[#{next_oid}]"
  end

end
