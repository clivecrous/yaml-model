require 'yaml-model'

describe YAML_Model, "::create" do

  class Person < YAML_Model
    type :name, String
  end

  before( :each ) do
    YAML_Model.reset!
  end

  it "ensures attribute types on creation" do
    lambda{ Person.create }.should raise_error( YAML_Model::Error )
  end

end

