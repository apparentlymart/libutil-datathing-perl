
=head1 NAME

Util::DataThing::Serializer - Abstract base class for objects that can serialize and deserialize Util::DataThing objects to various formats

=head1 SYNOPSIS

    my $serializer = Util::DataThing::Serializer::SomeSubclass->new();
    $serializer->serialize_object_to_stream($object, $fh);

=cut

package Util::DataThing::Serializer::JSON;

use strict;
use warnings;
use Carp;

sub serialize_object_to_string {
    Carp::croak("$_[0] does not implement serialize_object_to_string");
}

sub deserialize_object_from_string {
    Carp::croak("$_[0] does not implement deserialize_object_from_string");
}

sub serialize_object_to_stream {
    my ($self, $object, $stream) = @_;

    $stream->print($self->serialize_object_to_string($object));
}

sub deserialize_object_from_stream {
    my ($self, $stream, $class) = @_;

    return $self->deserialize_object_from_string(join('', <$stream>), $class);
}

=head1 METHODS

=head2 $string = $serializer->serialize_object_to_string($object)

Serializes the given L<Util::DataThing> object to a string and returns that string.

=head2 $object = $serializer->deserialize_object_from_string($string, $class)

Attempts to deserialize the given string to an object of the given
class, which must be a subclass of L<Util::DataThing>.

=head2 $serializer->serialize_object_to_stream($object, $stream)

Serializes the given L<Util::DataThing> object to a string and writes
the result to the given stream.

The stream must be some kind of L<IO> object.

=head2 $object = $serializer->deserialize_object_from_stream($stream, $class)

Attempts to deserialize data read from the given stream to an object of the given
class, which must be a subclass of L<Util::DataThing>.

 The stream must be some kind of L<IO> object.

=head1 INFORMATION FOR SUBCLASS IMPLEMENTORS

If you are developing a subclass of this class, you must provide implementations
for the serialize and deserialize functions based on strings.

Default implementations of the stream-based methods are provided which are
simple wrappers around the string-based methods. Subclasses should
override these if they are able to do something more sensible.

=cut

1;
