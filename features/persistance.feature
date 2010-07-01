Feature: Persistance
  In order to be able to use data in multiple sessions
  As an application
  I want whatever data I used to persist to disk as a YAML file

  Scenario: An empty model
    Given I have set the YAML::Model filename to a temporary file
    Given I have an empty model
    When YAML::Model saves
    Then the file contents of the temporary file and the "an_empty_model" yaml template should be identical
