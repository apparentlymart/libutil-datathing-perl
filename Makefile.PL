
use ExtUtils::MakeMaker;
WriteMakefile(
    'NAME' => 'Util::DataThing',
    'VERSION_FROM' => 'lib/Util/DataThing.pm',
    'PREREQ_PM'		=> {
    },
    ($] >= 5.005 ?
        (
            ABSTRACT_FROM => 'lib/Util/DataThing.pm',
            AUTHOR     => 'Martin Atkins <mart@degeneration.co.uk>'
        ) : ()
    ),
);

