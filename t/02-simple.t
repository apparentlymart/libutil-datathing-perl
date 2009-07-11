
use strict;
use warnings;
use Test::More tests => 12;

my $thing = Util::DataThing::Test::Class1->new(
    some_string => "Hello",
);

ok($thing->isa('Util::DataThing::Test::Class1'), 'Thing is of the right type');
ok($thing->can('some_string'), 'Thing can some_string');
is($thing->some_string, "Hello", "some_string has the value set in the constructor call");

$thing->some_string("Goodbye");
is($thing->some_string, "Goodbye", "some_string has an updated value");

ok(! defined($thing->some_integer), "some_integer is not yet defined");

$thing->some_integer(2);
is($thing->some_integer, 2, "some_integer is 2");

$thing->some_integer(3.6);
is($thing->some_integer, 3, "some_integer is 3");

$thing->some_integer(undef);
ok(! defined($thing->some_integer), "some_integer is undef again");

$thing->some_boolean(1);
is($thing->some_boolean, 1, "some_boolean is true");

$thing->some_boolean("dsgasf");
is($thing->some_boolean, 1, "some_integer is still true");

$thing->some_boolean(0);
is($thing->some_boolean, 0, "some_integer is false");

$thing->some_boolean(undef);
ok(! defined($thing->some_boolean), "some_boolean is undef");

exit(0);

package Util::DataThing::Test::Class1;

use Util::DataThing;
use base qw(Util::DataThing);

BEGIN {

    __PACKAGE__->register_property("some_string", Util::DataThing::STRING);
    __PACKAGE__->register_property("some_integer", Util::DataThing::INTEGER);
    __PACKAGE__->register_property("some_float", Util::DataThing::FLOAT);
    __PACKAGE__->register_property("some_boolean", Util::DataThing::BOOLEAN);

}





