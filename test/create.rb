require 'yaml-model'

describe YAML_Model, "::create" do

  class BadPerson < YAML_Model
    type :name, String
  end

  class Person < YAML_Model
    type :name, String
    init :name
  end

  before( :each ) do
    YAML_Model.reset!
  end

  it "ensures attribute types on creation" do
    lambda{ BadPerson.create }.should raise_error( YAML_Model::Error )
    lambda{ Person.create( "Bob" ) }.should_not raise_error( YAML_Model::Error )
  end

  it "ensures correct amount of arguments given" do
    lambda{ BadPerson.create( "Bob" ) }.should raise_error( ArgumentError )
    lambda{ Person.create( "Bob" ) }.should_not raise_error( ArgumentError )
    lambda{ BadPerson.create }.should_not raise_error( ArgumentError )
    lambda{ Person.create }.should raise_error( ArgumentError )
    lambda{ Person.create( "Bob", "Smith" ) }.should raise_error( ArgumentError )
  end

end

