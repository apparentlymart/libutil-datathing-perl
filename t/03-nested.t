
use strict;
use warnings;
use Test::More tests => 8;

my $thing1 = Util::DataThing::Test::Class1->new(
    some_string => "thing1",
);

my $thing2 = Util::DataThing::Test::Class2->new(
    some_string => "thing2",
);

$thing1->some_class2($thing2);
$thing2->some_class1($thing1);

is($thing1->some_string, "thing1");
is($thing2->some_string, "thing2");

is($thing1->some_class2->some_string, "thing2");
is($thing2->some_class1->some_string, "thing1");

is($thing1->some_class2->some_class1->some_string, "thing1");
is($thing2->some_class1->some_class2->some_string, "thing2");

$thing1->some_string("thing1-modified");
is($thing1->some_string, "thing1-modified");
is($thing1->some_class2->some_class1->some_string, "thing1-modified", "The class1 inside thing2 is backed by the same data as thing1");

exit(0);

package Util::DataThing::Test::Class1;

use Util::DataThing::Type;
use base qw(Util::DataThing);

BEGIN {

    __PACKAGE__->register_property("some_string", Util::DataThing::STRING);
    __PACKAGE__->register_property("some_class2", Util::DataThing::Type->object("Util::DataThing::Test::Class2"));

}

package Util::DataThing::Test::Class2;

use base qw(Util::DataThing);

BEGIN {

    __PACKAGE__->register_property("some_string", Util::DataThing::STRING);
    __PACKAGE__->register_property("some_class1", Util::DataThing::Type->object("Util::DataThing::Test::Class1"));

}

