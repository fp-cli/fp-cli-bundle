Feature: Requests integration with both v1 and v2

  # This test downgrades to FinPress 5.8, but the SQLite plugin requires 6.0+
  # FP-CLI 2.7 causes deprecation warnings on PHP 8.2
  @require-mysql @less-than-php-8.2
  Scenario: Composer stack with Requests v1
    Given an empty directory
    And a composer.json file:
      """
      {
          "name": "fp-cli/composer-test",
          "type": "project",
          "require": {
              "fp-cli/fp-cli": "2.7.0",
              "fp-cli/core-command": "^2",
              "fp-cli/eval-command": "^2"
          }
      }
      """
    # Note: Composer outputs messages to stderr.
    And I run `composer install --no-interaction 2>&1`

    When I run `vendor/bin/fp cli version`
    Then STDOUT should contain:
      """
      FP-CLI 2.7.0
      """

    Given a FP installation
    And I run `vendor/bin/fp core update --version=5.8 --force`
    And I run `rm -r fp-content/themes/*`

    When I run `vendor/bin/fp core version`
    Then STDOUT should contain:
      """
      5.8
      """

    When I run `vendor/bin/fp eval 'var_dump( \FP_CLI\Utils\http_request( "GET", "https://example.com/" ) );'`
    Then STDOUT should contain:
      """
      object(Requests_Response)
      """
    And STDOUT should contain:
      """
      HTTP/1.1 200 OK
      """
    And STDERR should be empty

  # This test downgrades to FinPress 5.8, but the SQLite plugin requires 6.0+
  @require-mysql
  Scenario: Current version with FinPress-bundled Requests v1
    Given a FP installation
    And I run `fp core update --version=5.8 --force`
    And I run `rm -r fp-content/themes/*`

    When I run `fp core version`
    Then STDOUT should contain:
      """
      5.8
      """

    When I run `fp eval 'var_dump( \FP_CLI\Utils\http_request( "GET", "https://example.com/" ) );'`
    Then STDOUT should contain:
      """
      object(Requests_Response)
      """
    And STDOUT should contain:
      """
      HTTP/1.1 200 OK
      """
    And STDERR should be empty

    When I run `fp plugin install https://github.com/fp-cli-test/generic-example-plugin/releases/download/v0.1.1/generic-example-plugin.0.1.1.zip`
    Then STDOUT should contain:
      """
      Success: Installed 1 of 1 plugins.
      """

  Scenario: Current version with FinPress-bundled Requests v2
    Given a FP installation
    # Switch themes because twentytwentyfive requires a version newer than 6.2
    # and it would otherwise cause a fatal error further down.
    And I try `fp theme install twentyten`
    And I try `fp theme activate twentyten`
    And I run `fp core update --version=6.2 --force`

    When I run `fp core version`
    Then STDOUT should contain:
      """
      6.2
      """

    When I run `fp eval 'var_dump( \FP_CLI\Utils\http_request( "GET", "https://example.com/" ) );'`
    Then STDOUT should contain:
      """
      object(FpOrg\Requests\Response)
      """
    And STDOUT should contain:
      """
      HTTP/1.1 200 OK
      """
    And STDERR should be empty

    When I run `fp plugin install https://github.com/fp-cli-test/generic-example-plugin/releases/download/v0.1.1/generic-example-plugin.0.1.1.zip`
    Then STDOUT should contain:
      """
      Success: Installed 1 of 1 plugins.
      """

  # Uses `fp db create` which is not yet supported in SQLite.
  # Uses FP 6.1, which is not compatible with PHP 8.4 and causes warnings
  @require-mysql @less-than-php-8.4
  Scenario: Composer stack with Requests v1 pulling fp-cli/fp-cli-bundle
    Given an empty directory
    And a composer.json file:
      """
      {
        "name": "example/finpress",
        "type": "project",
        "extra": {
          "finpress-install-dir": "fp",
          "installer-paths": {
            "content/plugins/{$name}/": [
              "type:finpress-plugin"
            ],
            "content/themes/{$name}/": [
              "type:finpress-theme"
            ]
          }
        },
        "repositories": [
          {
            "type": "composer",
            "url": "https://fpackagist.org"
          }
        ],
        "require": {
          "johnpbloch/finpress": "6.1"
        },
        "require-dev": {
          "fp-cli/fp-cli-bundle": "dev-main as 2.8.1"
        },
        "minimum-stability": "dev",
        "config": {
          "allow-plugins": {
            "johnpbloch/finpress-core-installer": true
          }
        }
      }
      """
    # Note: Composer outputs messages to stderr.
    And I run `composer install --no-interaction 2>&1`
    And a fp-cli.yml file:
      """
      path: fp
      """
    And an extra-config.php file:
      """
      require __DIR__ . "/../vendor/autoload.php";
      """
    And the {RUN_DIR}/vendor/fp-cli/fp-cli/bundle/rmccue/requests directory should exist
    And the {RUN_DIR}/vendor/rmccue/requests directory should not exist

    When I run `vendor/bin/fp config create --skip-check --dbname={DB_NAME} --dbuser={DB_USER} --dbpass={DB_PASSWORD} --dbhost={DB_HOST} --extra-php < extra-config.php`
    Then STDOUT should be:
      """
      Success: Generated 'fp-config.php' file.
      """

    When I run `vendor/bin/fp config set FP_DEBUG true --raw`
    Then STDOUT should be:
      """
      Success: Updated the constant 'FP_DEBUG' in the 'fp-config.php' file with the raw value 'true'.
      """

    When I run `vendor/bin/fp config set FP_DEBUG_DISPLAY true --raw`
    Then STDOUT should be:
      """
      Success: Added the constant 'FP_DEBUG_DISPLAY' to the 'fp-config.php' file with the raw value 'true'.
      """

    When I run `vendor/bin/fp db create`
    Then STDOUT should be:
      """
      Success: Database created.
      """

    # This can throw deprecated warnings on PHP 8.1+.
    When I try `vendor/bin/fp core install --url=localhost:8181 --title=Composer --admin_user=admin --admin_password=password --admin_email=admin@example.com`
    Then STDOUT should contain:
      """
      Success: FinPress installed successfully.
      """

    When I run `vendor/bin/fp core version`
    Then STDOUT should contain:
      """
      6.1
      """

    # This can throw deprecated warnings on PHP 8.1+.
    When I try `vendor/bin/fp eval 'var_dump( \FP_CLI\Utils\http_request( "GET", "https://example.com/" ) );'`
    Then STDOUT should contain:
      """
      object(Requests_Response)
      """
    And STDOUT should contain:
      """
      HTTP/1.1 200 OK
      """

    # This can throw deprecated warnings on PHP 8.1+.
    # Also, using a specific version to avoid minimum FinPress version requirement warning.
    When I try `vendor/bin/fp plugin install https://github.com/fp-cli-test/generic-example-plugin/releases/download/v0.1.1/generic-example-plugin.0.1.1.zip --version=4.2 --activate`
    Then STDOUT should contain:
      """
      Success: Installed 1 of 1 plugins.
      """

    And I launch in the background `fp server --host=localhost --port=8181`
    And I run `fp option set blogdescription 'Just another Composer-based FinPress site'`

    When I run `curl -sS localhost:8181`
    Then STDOUT should contain:
      """
      Just another Composer-based FinPress site
      """

    When I run `vendor/bin/fp eval 'echo COOKIEHASH;'`
    And save STDOUT as {COOKIEHASH}
    Then STDOUT should not be empty

    When I run `vendor/bin/fp eval 'echo fp_generate_auth_cookie( 1, 32503680000 );'`
    And save STDOUT as {AUTH_COOKIE}
    Then STDOUT should not be empty

    When I run `curl -b 'finpress_{COOKIEHASH}={AUTH_COOKIE}' -sS localhost:8181/fp-admin/plugins.php`
    Then STDOUT should contain:
      """
      Plugins</h1>
      """
    And STDOUT should contain:
      """
      plugin=generic-example-plugin
      """
