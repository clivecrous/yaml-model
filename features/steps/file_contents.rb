Then /^the file contents of "([^"]*)" and the "([^"]*)" yaml template should be identical$/ do |filename_a, filename_b|
  yaml_template_filename = File.expand_path( File.join( File.dirname( __FILE__ ), '..', 'fixtures', filename_b + '.yaml' ) )
  File.readlines( filename_a ).map{|n|n.chomp}.should == File.readlines( yaml_template_filename ).map{|n|n.chomp}
end

Then /^the file contents of the temporary file and the "([^"]*)" yaml template should be identical$/ do |filename|
  Then %{the file contents of "#{ @temporary_file_name }" and the "#{ filename }" yaml template should be identical}
end
