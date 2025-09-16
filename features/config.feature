Feature: fin-config.php tests

  # Regression test for https://github.com/fin-cli/extension-command/issues/247
  # Only testing on MySQL because the SQLite drop-in is not added to the custom directories in this test.
  @require-mysql
  Scenario: __FILE__ and __DIR__ in fin-config.php don't point into the PHAR filesystem
    Given a FIN installation
    And a new Phar with the same version
    And a fin-config.php file:
      """
      <?php
      define( 'DB_NAME', 'fin_cli_test' );
      define( 'DB_USER', '{DB_USER}' );
      define( 'DB_PASSWORD', '{DB_PASSWORD}' );
      define( 'DB_HOST', '{DB_HOST}' );
      define( 'DB_CHARSET', 'utf8' );
      define( 'DB_COLLATE', '' );
      $table_prefix = 'fin_';
      // Provide defines that make use of __FILE__ and __DIR__.
      define( 'FIN_CONTENT_DIR', __FILE__ . '/my-content/' );
      define( 'FIN_PLUGIN_DIR', __DIR__ . '/my-plugins/' );
      if ( ! defined( 'ABSPATH' ) )
        define( 'ABSPATH', dirname( __FILE__ ) . '/' );
      require_once( ABSPATH . 'fin-settings.php' );
      """

    When I run `{PHAR_PATH} eval "echo 'FIN_CONTENT_DIR => ' . FIN_CONTENT_DIR;"`
    Then STDOUT should not contain:
      """
      FIN_CONTENT_DIR => phar://
      """

    When I run `{PHAR_PATH} eval "echo 'FIN_PLUGIN_DIR => ' . FIN_PLUGIN_DIR;"`
    Then STDOUT should not contain:
      """
      FIN_PLUGIN_DIR => phar://
      """
