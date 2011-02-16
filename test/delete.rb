require 'yaml-model'

describe YAML_Model, ".delete" do

  DeleteModelInstance = Class.new( YAML_Model )

  DeleteModelInstanceOne = Class.new( YAML_Model )
  DeleteModelInstanceMany = Class.new( YAML_Model )

  class DeleteModelInstanceOne < YAML_Model
    has :many, DeleteModelInstanceMany
  end

  class DeleteModelInstanceMany < YAML_Model
    type :one, DeleteModelInstanceOne
    init :one
  end

  before( :each ) do
    YAML_Model.reset!
  end

  it "Deletes model instances from self" do
    a = DeleteModelInstance.create
    b = DeleteModelInstance.create
    c = DeleteModelInstance.create
    DeleteModelInstance.all.should == [ a, b, c ]
    b.delete
    DeleteModelInstance.all.should == [ a, c ]
    a.delete
    DeleteModelInstance.all.should == [ c ]
    c.delete
    DeleteModelInstance.all.should == [ ]
  end

  it "Deletes model instances when referenced" do
    one = DeleteModelInstanceOne.create
    many_a = DeleteModelInstanceMany.create( one )
    many_b = DeleteModelInstanceMany.create( one )

    many_a.delete

    DeleteModelInstanceMany.all.should == [ many_b ]
    one.many.should == [ many_b ]
  end

end
