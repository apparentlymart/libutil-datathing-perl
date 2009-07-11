
=head1 NAME

Util::DataThing - A simple framework for creating introspectable business objects

=head1 SYNOPSIS

    package ExampleApp::Person;
    use base qw(Util::DataThing);
    
    __PACKAGE__->declare_property('name', STRING);

=head1 DESCRIPTION

This class provides a framework for providing business objects
within an application.

Subclasses of this class support introspection via the
C<type> method, which returns a L<Util::DataThing::Type> object
describing the class.

The internal structure of the objects is opaque to subclasses
and should not be relied upon. Subclasses may define new methods
in addition to those created with this class's C<register_>
methods, but they should be implemented in terms of the
property accessors created by this class, not direct access
to the object internals.

This is not an ORM or other mechanism for abstracting away
your data access layer, but if you want to use an ORM then
objects created with this class may be a good thing for your
ORM to return.

TODO: Write more docs

=cut

package Util::DataThing;

use strict;
use warnings;
use Util::DataThing::Type;
use Carp qw(croak);
use Sub::Name;

our $VERSION = "0.01_01";

sub new {
    my $class = shift;

    my $args = (scalar(@_) == 1 ? $_[0] : {@_});

    my $self = bless {}, $class;
    $self->{data} = {};

    foreach my $property (keys %$args) {
        $self->$property($args->{$property});
    }

    return $self;
}

sub register_property {
    my ($class, $name, $type) = @_;

    my ($existing_type, $existing_class) = $class->type->property_type($name);
    croak("$class tried to override property ${existing_class}->$name") if $existing_type;

    # Create an accessor for this field
    {
        no strict 'refs';
        my $full_name = "${class}::${name}";

        my $coerce_in = $type->coerce_in;
        my $coerce_out = $type->coerce_out;

        my $method = sub {
            my $self = shift;

            if (@_) {
                my $value = shift;
                croak("Unexpected extra arguments to ${class}->${name}") if @_;
                return $self->{data}{$name} = defined($value) ? $coerce_in->($value, $type) : undef;
            }
            else {
                my $value = $self->{data}{$name};
                return defined($value) ? $coerce_out->($value, $type) : undef;
            }
        };

        Sub::Name::subname($full_name, $method);
        *{$full_name} = $method;
    }

    # Tell Util::DataThing::Type about this field using
    # our super-secret backdoor!
    Util::DataThing::Type->_register_object_property($class, $name, $type);
}

sub type {
    my ($thing) = @_;

    my $class = ref($thing) ? ref($thing) : $thing;
    return Util::DataThing::Type->object($class);
}

1;

=head1 AUTHOR AND COPYRIGHT

Written and maintained by Martin Atkins <mart@degeneration.co.uk>.

Copyright 2009 Six Apart Ltd. All Rights Reserved.

The items in this distribution may be distributed under the same
terms as Perl itself.


