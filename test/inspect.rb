require 'yaml-model'

describe YAML_Model, ".to_s" do

  InspectedModelReference = Class.new( YAML_Model )

  class InspectedModel < YAML_Model
    type :name, String
    type :at, Time
    type :reference, InspectedModelReference
    init :name, :at, :reference
  end

  before( :each ) do
    YAML_Model.reset!
  end

  it "Inspects with the correct information" do
    next_oid = YAML_Model.next_oid
    ref = InspectedModelReference.create
    at = Time.now
    model_1 = InspectedModel.create( 'foo', at, ref )
    model_1.inspect.should == "InspectedModel[#{next_oid+1}]{:at=>#{at.inspect},:name=>\"foo\",:reference=>InspectedModelReference[#{next_oid}]{}}"
    model_2 = InspectedModel.create( 'bar', at, ref )
    model_2.inspect.should == "InspectedModel[#{next_oid+2}]{:at=>#{at.inspect},:name=>\"bar\",:reference=>InspectedModelReference[#{next_oid}]{}}"
    InspectedModelReference.inspect.should == ref.inspect
    InspectedModel.inspect.should == "#{model_1.inspect}\n#{model_2.inspect}"
  end

end
