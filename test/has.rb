require 'yaml-model'

describe YAML_Model, "::has" do

  User = Class.new( YAML_Model )
  Post = Class.new( YAML_Model )
  Tag = Class.new( YAML_Model )
  MultiUserUser = Class.new( YAML_Model )
  MultiUserPost = Class.new( YAML_Model )

  class Post < YAML_Model
    type :user, User
    init :user
    has :tags, Tag, :many_to_many => true
  end

  class User < YAML_Model
    has :posts, Post
  end

  class Tag < YAML_Model
    has :posts, Post, :many_to_many => true
  end

  class MultiUserUser < YAML_Model
    has :posts_confirmed, MultiUserPost, MultiUserPost => :confirmed_by
    has :posts_created, MultiUserPost, MultiUserPost => :created_by
    has :posts, MultiUserPost
  end

  class MultiUserPost < YAML_Model
    type :created_by, MultiUserUser
    type :confirmed_by, MultiUserUser
    init :created_by, :confirmed_by
  end

  before( :each ) do
    YAML_Model.reset!
  end

  it "creates a method of the correct attribute name" do
    User.instance_methods.index( :posts ).should_not == nil
  end

  it "caters for multiple links to a single model" do
    creator_1 = MultiUserUser.create
    creator_2 = MultiUserUser.create
    confirmer_1 = MultiUserUser.create
    confirmer_2 = MultiUserUser.create

    post_1 = MultiUserPost.create( creator_1, confirmer_1 )
    post_2 = MultiUserPost.create( creator_1, confirmer_2 )
    post_3 = MultiUserPost.create( creator_2, confirmer_1 )
    post_4 = MultiUserPost.create( creator_1, creator_2 )

    post_1.created_by.id.should == creator_1.id
    post_2.created_by.id.should == creator_1.id
    post_3.created_by.id.should == creator_2.id
    post_4.created_by.id.should == creator_1.id

    post_1.confirmed_by.id.should == confirmer_1.id
    post_2.confirmed_by.id.should == confirmer_2.id
    post_3.confirmed_by.id.should == confirmer_1.id
    post_4.confirmed_by.id.should == creator_2.id

    creator_1.posts_created.size.should == 3
    creator_1.posts_created.map{|n|n.id}.sort.should == [ post_1.id, post_2.id, post_4.id ]
    creator_1.posts_confirmed.size.should == 0
    creator_1.posts_confirmed.map{|n|n.id}.sort.should == []
    creator_1.posts.size.should == 3
    creator_1.posts.map{|n|n.id}.sort.should == [ post_1.id, post_2.id, post_4.id ]

    creator_2.posts_created.size.should == 1
    creator_2.posts_created.map{|n|n.id}.sort.should == [ post_3.id ]
    creator_2.posts_confirmed.size.should == 1
    creator_2.posts_confirmed.map{|n|n.id}.sort.should == [ post_4.id ]
    creator_2.posts.size.should == 2
    creator_2.posts.map{|n|n.id}.sort.should == [ post_3.id, post_4.id ]

    confirmer_1.posts_created.size.should == 0
    confirmer_1.posts_created.map{|n|n.id}.sort.should == []
    confirmer_1.posts_confirmed.size.should == 2
    confirmer_1.posts_confirmed.map{|n|n.id}.sort.should == [ post_1.id, post_3.id ]
    confirmer_1.posts.size.should == 2
    confirmer_1.posts.map{|n|n.id}.sort.should == [ post_1.id, post_3.id ]

    confirmer_2.posts_created.size.should == 0
    confirmer_2.posts_created.map{|n|n.id}.sort.should == []
    confirmer_2.posts_confirmed.size.should == 1
    confirmer_2.posts_confirmed.map{|n|n.id}.sort.should == [ post_2.id]
    confirmer_2.posts.size.should == 1
    confirmer_2.posts.map{|n|n.id}.sort.should == [ post_2.id ]
  end

  it "correctly references items that belong to it" do
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
    Post.instance_methods.index( :add_tag ).should_not == nil
    Tag.instance_methods.index( :add_post ).should_not == nil
  end

  it "handles many to many relationships seamlessly" do
    dummy_user = User.create

    post_a = Post.create( dummy_user )
    post_b = Post.create( dummy_user )
    post_c = Post.create( dummy_user )

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
