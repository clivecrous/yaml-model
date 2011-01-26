require 'yaml-model'

describe YAML_Model, "::has" do

  before( :each ) do
    YAML_Model.reset!
  end

  it "creates a method of the correct attribute name" do
    User = Class.new( YAML_Model )
    class User < YAML_Model
      has :posts, Class.new( YAML_Model )
    end
    User.instance_methods.index( :posts ).should_not == nil
  end

  it "correctly references items that belong to it" do
    User = Class.new( YAML_Model )
    Post = Class.new( YAML_Model )
    class Post < YAML_Model
      type :user, User
      init :user
    end
    class User < YAML_Model
      has :posts, Post
    end

    user_a = User.create
    user_b = User.create
    user_c = User.create
    post_a = Post.create( user_a )
    post_b = Post.create( user_a )
    post_c = Post.create( user_c )

    user_a.posts.should == [ post_a, post_b ]
    user_b.posts.should == []
    user_c.posts.should == [ post_c ]
  end

  it "adds an add_ method when the relationship is many_to_many" do
    Tag = Class.new( YAML_Model )
    Post = Class.new( YAML_Model )
    class Post < YAML_Model
      has :tags, Tag, :many_to_many
    end
    Post.instance_methods.index( :add_tag ).should_not == nil
    Tag.instance_methods.index( :add_post ).should == nil
  end

  it "handles many to many relationships seamlessly" do
    Tag = Class.new( YAML_Model )
    Post = Class.new( YAML_Model )
    Post.has :tags, Tag, :many_to_many
    Tag.has :posts, Post, :many_to_many

    post_a = Post.create
    post_b = Post.create
    post_c = Post.create

    tag_a = Tag.create
    tag_b = Tag.create
    tag_c = Tag.create

    post_a.add_tag( tag_a )
    post_a.add_tag( tag_b )
    tag_b.add_post( post_c )

    post_a.tags.sort.should == [ tag_a, tag_b ].sort
    post_b.tags.should == []
    post_c.tags.should == [ tag_b ]

    tag_a.posts.should == [ post_a ]
    tag_b.posts.sort.should == [ post_a, post_c ].sort
    tag_c.posts.should == []
  end

end
