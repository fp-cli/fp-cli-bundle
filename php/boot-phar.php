<?php

if ( 'cli' !== PHP_SAPI ) {
	echo "FP-CLI only works correctly from the command line, using the 'cli' PHP SAPI.\n",
		"You're currently executing the FP-CLI binary via the '" . PHP_SAPI . "' PHP SAPI.\n",
		"In case you were trying to run this file with a web browser, know that this cannot technically work.\n",
		"When running the FP-CLI binary on the command line, you can ensure you're using the right PHP SAPI",
		"by checking that `php -v` has the word 'cli' in the first line of output.\n";
	die( -1 );
}

// Store the path to the Phar early on for `Utils\phar-safe-path()` function.
define( 'FP_CLI_PHAR_PATH', Phar::running( true ) );

if ( file_exists( 'phar://fp-cli.phar/php/fp-cli.php' ) ) {
	define( 'FP_CLI_ROOT', 'phar://fp-cli.phar' );
	include FP_CLI_ROOT . '/php/fp-cli.php';
} elseif ( file_exists( 'phar://fp-cli.phar/vendor/fp-cli/fp-cli/php/fp-cli.php' ) ) {
	define( 'FP_CLI_ROOT', 'phar://fp-cli.phar/vendor/fp-cli/fp-cli' );
	include FP_CLI_ROOT . '/php/fp-cli.php';
} else {
	echo "Couldn't find 'php/fp-cli.php'. Was this Phar built correctly?";
	exit( 1 );
}
