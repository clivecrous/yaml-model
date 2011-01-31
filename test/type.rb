require 'yaml-model'

describe YAML_Model, "::type" do

  before( :each ) do
    YAML_Model.reset!
  end

  class ShouldCreateClassMethodsForAttributeDefaultValues_nil < YAML_Model
    type :name, String
  end

  class ShouldCreateClassMethodsForAttributeDefaultValues_Bob < YAML_Model
    type :name, String, :default => 'Bob'
  end

  it "should create class methods for attribute default values" do
    ShouldCreateClassMethodsForAttributeDefaultValues_nil.respond_to?( :__name__default ).should == true
    ShouldCreateClassMethodsForAttributeDefaultValues_nil.__name__default.should == nil
    lambda{ShouldCreateClassMethodsForAttributeDefaultValues_nil.create}.should raise_error YAML_Model::Error
    ShouldCreateClassMethodsForAttributeDefaultValues_Bob.respond_to?( :__name__default ).should == true
    ShouldCreateClassMethodsForAttributeDefaultValues_Bob.__name__default.should == 'Bob'
    lambda{ShouldCreateClassMethodsForAttributeDefaultValues_Bob.create}.should_not raise_error YAML_Model::Error
    ShouldCreateClassMethodsForAttributeDefaultValues_Bob.create.name.should == ShouldCreateClassMethodsForAttributeDefaultValues_Bob.__name__default
  end
end
