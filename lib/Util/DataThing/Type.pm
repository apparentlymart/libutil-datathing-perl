
=head1 NAME

Util::DataThing::Type - Represents the type of a property in L<Util::DataThing>

=cut

package Util::DataThing::Type;

use strict;
use warnings;
use Carp qw(croak confess);
use overload "<=>" => \&_compare, '""' => sub { $_[0]->{display_name} };
use Scalar::Util;
use Sub::Name;
use MRO::Compat;

my %primitives;
my %primitive_coerce;
my %objects;
my %object_properties;

BEGIN {

    %primitives = ();
    %primitive_coerce = (
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
    %objects = ();
    %object_properties = ();


    foreach my $type_name (qw(string integer float boolean any)) {
        my $obj = bless {}, __PACKAGE__;
        $obj->{display_name} = '('.$type_name.')';
        my $coerce = $primitive_coerce{$type_name};
        Sub::Name::subname("_coerce_".$type_name, $coerce);
        $obj->{coerce_in} = $coerce;
        $obj->{coerce_out} = $coerce;

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

    my $self = bless {}, __PACKAGE__;
    $self->{display_name} = $object_class;
    $self->{object_class} = $object_class;
    $self->{coerce_in} = sub {
        my ($value) = @_;

        my $class = $self->object_class;
        confess("Only $class objects can be assigned to this field.") unless UNIVERSAL::isa($value, $class);

        return $value->{data};
    };
    $self->{coerce_out} = sub {
        my ($value) = @_;

        my $class = $self->object_class;
        my $obj = { data => $value };
        return bless $obj, $class;
    };

    Sub::Name::subname("_coerce_in_object", $self->{coerce_in});
    Sub::Name::subname("_coerce_out_object", $self->{coerce_out});

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

sub for_each_property {
    my ($self, $code) = @_;

    return unless $self->is_object;

    my $object_class = $self->object_class;

    my $all_classes = mro::get_linear_isa($object_class);

    for (my $i = scalar(@$all_classes) - 1; $i >= 0; $i--) {
        my $class = $all_classes->[$i];
        my $properties = $object_properties{$class};
        next unless $properties;

        map { $code->($_, $properties->{$_}) } keys %$properties;
    }

}

sub properties {
    my ($self) = @_;

    return {} unless $self->is_object;

    my $ret = {};
    $self->for_each_property(sub {
        $ret->{$_[0]} = $_[1];
    });
    return $ret;
}

sub property_type {
    my ($self, $property_name) = @_;

    return undef unless $self->is_object;

    my $want_array = wantarray;

    my $object_class = $self->object_class;

    my $all_classes = mro::get_linear_isa($object_class);

    for (my $i = 0; $i < scalar(@$all_classes); $i++) {
        my $class = $all_classes->[$i];
        my $properties = $object_properties{$class};
        next unless $properties;

        if ($want_array) {
            return $properties->{$property_name}, $class if defined($properties->{$property_name});
        }
        else {
            return $properties->{$property_name} if defined($properties->{$property_name});
        }
    }

    # If we fall out here then no parent class has the
    # property we're looking for.
    return undef;
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
