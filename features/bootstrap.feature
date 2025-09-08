Feature: Bootstrap FP-CLI

  Scenario: Override command bundled with freshly built PHAR

    Given an empty directory
    And a new Phar with the same version
    And a cli-override-command/cli.php file:
      """
      <?php
      if ( ! class_exists( 'FP_CLI' ) ) {
        return;
      }
      $autoload = dirname( __FILE__ ) . '/vendor/autoload.php';
      if ( file_exists( $autoload ) ) {
        require_once $autoload;
      }
      FP_CLI::add_command( 'cli', 'CLI_Command', array( 'when' => 'before_fp_load' ) );
      """
    And a cli-override-command/src/CLI_Command.php file:
      """
      <?php
      class CLI_Command extends FP_CLI_Command {
        public function version() {
          FP_CLI::success( "FP-Override-CLI" );
        }
      }
      """
    And a cli-override-command/composer.json file:
      """
      {
        "name": "fp-cli/cli-override",
        "description": "A command that overrides the bundled 'cli' command.",
        "autoload": {
          "psr-4": { "": "src/" },
          "files": [ "cli.php" ]
        },
        "extra": {
          "commands": [
            "cli"
          ]
        }
      }
      """
    And I run `composer install --working-dir={RUN_DIR}/cli-override-command --no-interaction 2>&1`

    When I run `{PHAR_PATH} cli version`
    Then STDOUT should contain:
      """
      FP-CLI
      """

    When I run `{PHAR_PATH} --require=cli-override-command/cli.php cli version`
    Then STDOUT should contain:
      """
      FP-Override-CLI
      """

  Scenario: Template paths should be resolved correctly when PHAR is renamed

    Given an empty directory
    And a new Phar with the same version
    And a FP installation
    And I run `fp plugin install https://github.com/fp-cli-test/generic-example-plugin/releases/download/v0.1.1/generic-example-plugin.0.1.1.zip --activate`
    And I run `fp plugin deactivate generic-example-plugin`

    When I run `php {PHAR_PATH} plugin status generic-example-plugin`
    Then STDOUT should contain:
      """
      Plugin generic-example-plugin details:
          Name: Example Plugin
          Status: Inactive
      """
    And STDERR should be empty

    When I run `cp {PHAR_PATH} fp-renamed.phar`
    And I try `php fp-renamed.phar plugin status generic-example-plugin`
    Then STDOUT should contain:
      """
      Plugin generic-example-plugin details:
          Name: Example Plugin
          Status: Inactive
      """
    And STDERR should be empty
