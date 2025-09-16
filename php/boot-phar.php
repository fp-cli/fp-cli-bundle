<?php

if ( 'cli' !== PHP_SAPI ) {
	echo "FIN-CLI only works correctly from the command line, using the 'cli' PHP SAPI.\n",
		"You're currently executing the FIN-CLI binary via the '" . PHP_SAPI . "' PHP SAPI.\n",
		"In case you were trying to run this file with a web browser, know that this cannot technically work.\n",
		"When running the FIN-CLI binary on the command line, you can ensure you're using the right PHP SAPI",
		"by checking that `php -v` has the word 'cli' in the first line of output.\n";
	die( -1 );
}

// Store the path to the Phar early on for `Utils\phar-safe-path()` function.
define( 'FIN_CLI_PHAR_PATH', Phar::running( true ) );

if ( file_exists( 'phar://fin-cli.phar/php/fin-cli.php' ) ) {
	define( 'FIN_CLI_ROOT', 'phar://fin-cli.phar' );
	include FIN_CLI_ROOT . '/php/fin-cli.php';
} elseif ( file_exists( 'phar://fin-cli.phar/vendor/fin-cli/fin-cli/php/fin-cli.php' ) ) {
	define( 'FIN_CLI_ROOT', 'phar://fin-cli.phar/vendor/fin-cli/fin-cli' );
	include FIN_CLI_ROOT . '/php/fin-cli.php';
} else {
	echo "Couldn't find 'php/fin-cli.php'. Was this Phar built correctly?";
	exit( 1 );
}
