require 'yaml'
require 'yaml-model/version'

class YAML_Model

  def self.inherited( child )
    child.instance_eval('@__attributes = {}')
    child.define_singleton_method( :attributes ) do
      @__attributes
    end
  end

  class Error < Exception
  end

  def self.reset!
    @@database_filename = nil

    @@database = {
      :next_oid => 1,
      :data => {}
    }
  end

  reset!

  attr_reader :id

  @@volatile = [ :@volatile ]

  def self.all
    @@database[ :data ][ self.name ] ||= []
  end

  def self.assert( assertion, info )
    raise Error.new( info.inspect ) unless assertion
  end

  def self.assert_type( variable, types )
    assert( [types].flatten.inject(false){|result,type|result||=(type===variable)}, "Invalid type: `#{variable.class.name}`" )
  end

  def self.type attr, types, options = {}, &block
    @__attributes[ attr ] = [ types, options ]
    define_method attr do
      instance_eval "@#{attr}"
    end
    define_method "#{attr}=".to_sym do |value|
      YAML_Model.assert_type value, types
      instance_exec( value, &block ) if block_given?
      instance_eval "@#{attr} = value"
    end
    define_singleton_method "__#{attr}__default".to_sym do
      options[ :default ]
    end
    define_method "__#{attr}__assert_type" do
      YAML_Model.assert_type( instance_eval( "@#{attr}" ), types )
    end
  end

  def initialize
    self.class.attributes.keys.each do |attribute|
      instance_eval( "@#{attribute} ||= self.class.__#{attribute}__default" )
      instance_eval( "__#{attribute}__assert_type" )
    end
  end

  def self.init *attributes, &block
    define_method :initialize do |*args|
      raise ArgumentError.new( "wrong number of arguments (#{args.size} for #{attributes.size}" ) unless args.size == attributes.size

      attributes.each do |attribute|
        value = args.shift
        self.send( "#{attribute}=".to_sym, value )
      end

      # FIXME For some reason commands within this block to set attribute values
      # require the `self.` prefix or they just don't work
      self.instance_eval( &block ) if block_given?

      super()
    end
  end

  def self.[]( id )
    all.select{|n|n.id==id}.first
  end

  def self.load!
    @@database = YAML.load( File.read( @@database_filename.to_s ) ) if File.exists?( @@database_filename.to_s )
  end

  def self.filename=( filename )
    @@database_filename = filename
    self.load!
  end

  def self.to_yaml
    @@database.to_yaml
  end

  def self.save!
    if @@database_filename
      File.open( @@database_filename, 'w' ) do |file|
        file.write( self.to_yaml )
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
      @id = @@database[ :next_oid ]
      @id.freeze
    end
    @@database[ :next_oid ] += 1
    @@database[ :data ][ this.class.name ] ||= []
    @@database[ :data ][ this.class.name ] << this
    this
  end

  def delete
    @@database[ :data ][ self.class.name ].delete( self )
  end

  def self.sort_by( *attributes )
    define_method '<=>'.to_sym do |other|
      attributes.map{|a|self.send(a)} <=> attributes.map{|a|other.send(a)}
    end
  end

  sort_by :id

  def self.has( that_attribute_plural, that_class, many_to_many = false )
    if many_to_many
      this_class = self
      this_class_name, that_class_name = [this_class,that_class].map{|n|n.name.split(':')[-1]}
      this_attribute_singular = this_class_name.downcase.to_sym
      that_attribute_singular = that_class_name.downcase.to_sym
      via_class_name = [ this_class_name, that_class_name ].sort.map{|n|n.capitalize}.join('')
      via_class = eval( "#{via_class_name}||=Class.new(YAML_Model) do
  type :#{this_attribute_singular}, #{this_class}
  type :#{that_attribute_singular}, #{that_class}
  init #{[this_attribute_singular,that_attribute_singular].sort.map{|n|":#{n}"}.join(',')}
end" )
      via_attribute_plural = ( via_class_name.downcase + "s" ).to_sym

      this_class.has via_attribute_plural, via_class

      define_method that_attribute_plural do
        send( via_attribute_plural ).map do |via_instance|
          via_instance.send( that_attribute_singular )
        end
      end

      define_method "add_#{that_attribute_singular}".to_sym do |that_instance|
        via_instance = ( ( this_attribute_singular < that_attribute_singular ) ? via_class.create( self, that_instance ) : via_class.create( that_instance, self ) )
        via_instance.send( "#{this_attribute_singular}=".to_sym, self )
        via_instance.send( "#{that_attribute_singular}=".to_sym, that_instance )
      end

    else

      define_method that_attribute_plural do
        that_class.select do |that_instance|
          that_instance.instance_variables.inject( false ) do |result,variable|
            result ||= that_instance.instance_eval(variable.to_s).class == self.class && that_instance.instance_eval(variable.to_s).id == self.id
          end
        end
      end

    end
  end

  at_exit { self.save! }

end
