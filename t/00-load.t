#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'Face::Client' ) || print "Bail out!\n";
}

diag( "Testing Face::Client $Face::Client::VERSION, Perl $], $^X" );
