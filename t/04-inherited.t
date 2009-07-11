
use strict;
use warnings;
use Test::More tests => 5;

my $thing = Util::DataThing::Test::Class2->new(
    some_string => "thing",
);

is($thing->some_string, "thing", "Can access property from parent class");
ok(defined($thing->type->property_type("some_string")), "Can get the type of property from parent class");

my $properties = $thing->type->properties;
ok(defined($properties->{some_string}), "Able to retrieve the inherited property");
ok(defined($properties->{some_other_string}), "Able to retrieve the local property");

package Util::DataThing::Test::Class1;

use Util::DataThing::Type;
use base qw(Util::DataThing);

BEGIN {

    __PACKAGE__->register_property("some_string", Util::DataThing::STRING);

}

package Util::DataThing::Test::Class2;

use base qw(Util::DataThing::Test::Class1);

BEGIN {

    eval {
        __PACKAGE__->register_property("some_string", Util::DataThing::STRING);
    };
    Test::More::ok($@, "Trapped attempt to override property in subclass");
    __PACKAGE__->register_property("some_other_string", Util::DataThing::STRING);

}

