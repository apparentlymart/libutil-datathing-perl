
=head1 NAME

Util::DataThing::Type - Represents the type of a property in L<Util::DataThing>

=cut

package Util::DataThing::Type;

use strict;
use warnings;
use Carp qw(croak confess);
use overload "<=>" => \&_compare;
use Scalar::Util;

my %primitives = ();
my %primitive_coerce = (
    string => sub {
        return "".$_[0];
    },
    integer => sub {
        return int($_[0])+0;
    },
    float => sub {
        return $_[0]+0;
    },
    boolean => sub {
        return $_[0] ? 1 : 0;
    },
    any => sub {
        return $_[0];
    },
);
my %objects = ();
my %object_properties = ();

BEGIN {
    foreach my $type_name (qw(string integer float boolean any)) {
        my $obj = bless {}, __PACKAGE__;
        $obj->{display_name} = '('.$type_name.')';
        $obj->{coerce_in} = $primitive_coerce{$type_name};
        $obj->{coerce_out} = $primitive_coerce{$type_name};

        $primitives{$type_name} = $obj;

        # We also create a convenient constant in Util::DataThing
        # so that subclasses can write, for example, STRING instead
        # of Util::DataThing::Type->primitive('string').
        my $sub_name = 'Util::DataThing::'.uc($type_name);
        {
            no strict 'refs';
            *{$sub_name} = sub { $obj };
        }
    }
}

sub primitive {
    my ($class, $type_name) = @_;

    return $primitives{$type_name} or croak "There is no primitive type called $type_name";
}

sub object {
    my ($class, $object_class) = @_;

    return $objects{$object_class} if defined($objects{$object_class});

    croak "Can only create Util::DataThing::Type instances for subclasses of Util::DataThing" unless UNIVERSAL::isa($object_class, 'Util::DataThing');

    my $self = bless {}, __PACKAGE__;
    $self->{display_name} = $object_class;
    $self->{object_class} = $object_class;
    $self->{coerce_in} = sub {
        my ($value) = @_;

        my $class = $self->object_class;
        confess("Only $class objects can be assigned to this field") unless UNIVERSAL::isa($value, $class);

        return $value->{data};
    };
    $self->{coerce_out} = sub {
        my ($value) = @_;

        my $class = $self->object_class;
        return $class->new($value);
    };

    # Ensure that we only end up with one instance in memory for each
    # class at any time, but also that we don't end up with
    # a giant cache of unused types.
    $objects{$object_class} = $self;
    Scalar::Util::weaken($objects{$object_class});

    return $self;
}

sub is_object {
    return defined($_[0]->{object_class}) ? 1 : 0;
}

sub object_class {
    return $_[0]->{object_class};
}

sub properties {
    my ($self) = @_;

    # FIXME: This needs to look at parent classes too.
    return {} unless $self->is_object;
    my $object_class = $self->object_class;
    return $object_properties{$object_class};
}

sub property_type {
    my ($self, $property_name) = @_;

    return $self->properties->{$property_name};
}

# Arrays and maps are not yet supported
sub is_array {
    return 0;
}
sub is_map {
    return 0;
}
sub inner_type {
    return undef;
}

sub coerce_in {
    if (@_ == 2) {
        return $_[0]->{coerce_in}->($_[1]);
    }
    else {
        return $_[0]->{coerce_in};
    }
}

sub coerce_out {
    if (@_ == 2) {
        return $_[0]->{coerce_out}->($_[1]);
    }
    else {
        return $_[0]->{coerce_out};
    }
}

sub compare {
    my ($a, $b, $reversed) = @_;

    # Fast path for our singleton primitive types
    return 0 if $a == $b;

    return -1 unless $a->isa('Util::ObjectThing::Type') && $b->isa('Util::ObjectThing::Type');

    if ($a->is_object && $b->is_object) {
        return $a->object_class cmp $b->object_class;
    }

    if ($a->is_array && $b->is_array) {
        return $a->inner_type <=> $b->inner_type;
    }

    if ($a->is_map && $b->is_map) {
        return $a->inner_type <=> $b->inner_type;
    }

    return -1;

}

sub _register_object_property {
    my ($class, $object_class, $property_name, $type) = @_;

    $object_properties{$object_class} ||= {};
    $object_properties{$object_class}{$property_name} = $type;
}

1;
