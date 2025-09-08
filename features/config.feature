Feature: fp-config.php tests

  # Regression test for https://github.com/fp-cli/extension-command/issues/247
  # Only testing on MySQL because the SQLite drop-in is not added to the custom directories in this test.
  @require-mysql
  Scenario: __FILE__ and __DIR__ in fp-config.php don't point into the PHAR filesystem
    Given a FP installation
    And a new Phar with the same version
    And a fp-config.php file:
      """
      <?php
      define( 'DB_NAME', 'fp_cli_test' );
      define( 'DB_USER', '{DB_USER}' );
      define( 'DB_PASSWORD', '{DB_PASSWORD}' );
      define( 'DB_HOST', '{DB_HOST}' );
      define( 'DB_CHARSET', 'utf8' );
      define( 'DB_COLLATE', '' );
      $table_prefix = 'fp_';
      // Provide defines that make use of __FILE__ and __DIR__.
      define( 'FP_CONTENT_DIR', __FILE__ . '/my-content/' );
      define( 'FP_PLUGIN_DIR', __DIR__ . '/my-plugins/' );
      if ( ! defined( 'ABSPATH' ) )
        define( 'ABSPATH', dirname( __FILE__ ) . '/' );
      require_once( ABSPATH . 'fp-settings.php' );
      """

    When I run `{PHAR_PATH} eval "echo 'FP_CONTENT_DIR => ' . FP_CONTENT_DIR;"`
    Then STDOUT should not contain:
      """
      FP_CONTENT_DIR => phar://
      """

    When I run `{PHAR_PATH} eval "echo 'FP_PLUGIN_DIR => ' . FP_PLUGIN_DIR;"`
    Then STDOUT should not contain:
      """
      FP_PLUGIN_DIR => phar://
      """
