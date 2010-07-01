Given /^I have set the YAML::Model filename to "([^"]*)"$/ do |filename|
  YAML::Model.filename = filename
end

Given /^I have set the YAML::Model filename to a temporary file$/ do
  temporary_file = Tempfile.new( "yaml_model-" )
  @temporary_file_name = temporary_file.path
  temporary_file.close!
  Given %{I have set the YAML::Model filename to "#{ @temporary_file_name }"}
end
