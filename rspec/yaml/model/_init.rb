describe YAML::Model, "::init" do

  before( :each ) do
    YAML::Model.reset!
  end

  it "runs the block it's given" do
    $ran_it = false
    class Test < YAML::Model
      init do
        $ran_it = true
      end
    end
    $ran_it.should == false
    Test.create
    $ran_it.should == true
  end

  it "can set instance varibles inside blocks it's given" do
    class Test < YAML::Model
      type :name, String
      init :name do
        @name = "Bar"
      end
    end
    test = Test.create( "Foo" )
    test.name.should == "Bar"
  end

end
