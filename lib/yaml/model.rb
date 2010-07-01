require 'yaml'

class YAML::Model

  class Error < Exception
  end

  attr_reader :id

  @@next_oid = 1
  @@filename = nil
  @@data = Hash.new{|h,k|h[k]=[]}
  @@volatile = [ :@volatile ]

  def self.next_oid
    @@next_oid += 1
  end

  def self.all
    @@data[ self ]
  end

  def assert( assertion, info )
    raise Error.new( info.inspect ) unless assertion
  end

  def assert_type( variable, types )
    assert( [types].flatten.inject(false){|result,type|result||=(type===variable)}, "Invalid type: `#{variable.class.name}`" )
  end

  def self.type attribute, types, &block
    define_method attribute do
      instance_eval "@#{attribute}"
    end
    define_method "#{attribute}=".to_sym do |value|
      assert_type value, types
      instance_exec( value, &block ) if block_given?
      instance_eval "@#{attribute} = value"
    end
  end

  def self.init *attributes, &block
    define_method :initialize do |*args|
      attributes.each do |attribute|
        self.send( "#{attribute}=".to_sym, args.shift )
        self.instance_eval( &block ) if block_given?
      end
    end
  end

  def self.[]( id )
    all.select{|n|n.id==id}.first
  end

  def self.load( filename )
    @@data[ File.expand_path( filename ) ] = YAML.load( File.read( filename ) ) if File.exists?( filename )
  end

  def self.load!
    self.load( @@filename )
  end

  def self.filename=( filename )
    @@filename = filename
    self.load!
  end

  def self.filename
    @@filename
  end

  def filename
    @@filename
  end

  def self.save!
    next_oid = YAML::Model.next_oid
    data_by_filename = Hash.new{|h,k|h[k]=[]}
    @@data.to_a.map do |klass,instances|
      instances.map do |instance|
        data_by_filename[ instance.filename ] << instance
      end
    end.uniq
    p '-'*80
    p @@data,data_by_filename
    p '-'*80
    data_by_filename.keys.each do |filename|
      File.open( filename, 'w' ) do |file|
        file.write( { :next_oid => next_oid, :data => data_by_filename[ filename ] }.to_yaml )
      end
    end
  end

  def self.each &block
    all.each &block
  end

  def self.select &block
    all.select &block
  end

  def self.filter hash
    select do |this|
      hash.keys.inject( true ) do |result,variable|
        this.instance_eval( "@#{variable}" ) == hash[ variable ]
      end
    end
  end

  def self.volatile variable
    @@volatile << "@#{variable}".to_sym
  end

  def to_yaml_properties
    instance_variables - @@volatile
  end

  def self.create( *args )
    this = self.new( *args )
    this.instance_eval do
      @id = YAML::Model.next_oid
      @id.freeze
    end
    @@data[ this.class ] ||= []
    @@data[ this.class ] << this
    this
  end

  def delete
    @@data[ self.class ].delete( self )
  end

  def <=>( other )
    self.id <=> other.id
  end

  def self.has( attribute_name, klass )
    define_method attribute_name do
      klass.select do |this|
        this.instance_variables.inject( false ) do |result,variable|
          result ||= this.instance_eval(variable).class == self.class && this.instance_eval(variable).id == self.id
        end
      end
    end
  end

  at_exit { self.save! }

end
