require 'yaml-model'

describe YAML_Model, "::init" do

  before( :each ) do
    YAML_Model.reset!
  end

  it "runs the block it's given" do
    $ran_it = false
    Test = Class.new( YAML_Model )
    class Test < YAML_Model
      init do
        $ran_it = true
      end
    end
    $ran_it.should == false
    Test.create
    $ran_it.should == true
  end

  it "can set instance varibles inside blocks it's given" do
    Test = Class.new( YAML_Model )
    class Test < YAML_Model
      type :name, String
      init :name do
        @name = "Bar"
      end
    end
    test = Test.create( "Foo" )
    test.name.should == "Bar"
  end

end
