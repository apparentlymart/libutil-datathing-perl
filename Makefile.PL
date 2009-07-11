
use ExtUtils::MakeMaker;
WriteMakefile(
    'NAME' => 'Util::DataThing',
    'VERSION_FROM' => 'lib/Util/DataThing.pm',
    'PREREQ_PM'		=> {
        'Sub::Name' => 0,
        'Carp' => 0,
        'Scalar::Util' => 0,
    },
    ($] >= 5.005 ?
        (
            ABSTRACT_FROM => 'lib/Util/DataThing.pm',
            AUTHOR     => 'Martin Atkins <mart@degeneration.co.uk>'
        ) : ()
    ),
);

