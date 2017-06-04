require File.expand_path(File.dirname(__FILE__)) + '/helper'

class TestParameters < Test::Unit::TestCase
  
  def setup
    @class = Class.new do
      include Tracksperanto::Parameters
    end
  end
  
  def test_parameters_empty_by_default
    assert_equal [], @class.parameters
  end
  
  def test_parameter_initialization
    flexmock(@class).should_receive(:attr_accessor).once.with(:foo)
    @class.parameter :foo
    assert_equal 1, @class.parameters.length
    
    first_param = @class.parameters[0]
    assert_equal :foo, first_param.name
    assert_nil first_param.desc
  end

  def test_parameter_initialization_with_safety
    flexmock(@class).should_receive(:attr_accessor).once.with(:foo)
    flexmock(@class).should_receive(:safe_reader).once.with(:foo)
    @class.parameter :foo, :required => true
  end
  
  def test_parameter_initialization_with_cast
    flexmock(@class).should_receive(:attr_accessor).once.with(:foo)
    flexmock(@class).should_receive(:cast_to_junk).once.with(:foo)
    @class.parameter :foo, :cast => :junk
  end
  
end
