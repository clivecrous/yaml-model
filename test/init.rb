require 'yaml-model'

describe YAML_Model, "::init" do

  class RunsTheBlockItsGiven < YAML_Model
    init do
      $ran_it = true
    end
  end

  class CanSetInstanceVariables < YAML_Model
    type :name, String
    init :name do
      self.name = "Bar"
    end
  end

  class SettingOfDefaultValues < YAML_Model
    type :name, String
    init do
      self.name = "Bob"
    end
  end

  before( :each ) do
    YAML_Model.reset!
  end

  it "runs the block it's given" do
    $ran_it = false
    $ran_it.should == false
    RunsTheBlockItsGiven.create
    $ran_it.should == true
  end

  it "can set instance variables inside blocks it's given" do
    test = CanSetInstanceVariables.create( "Foo" )
    test.name.should == "Bar"
  end

  it "allows setting of default values" do
    test = SettingOfDefaultValues.create
    test.name.should == "Bob"
  end

end
