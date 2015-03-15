use strict;
use warnings;

use Module::Build;

Module::Build->new(
    module_name       => 'Getopt::Long::DescriptivePod',
    license           => 'perl',
    dist_abstract     => 'Getopt::Long::DescriptivePod - write usage to Pod',
    dist_author       => 'Steffen Winkler <steffenw at cpan.org>',
    dist_version_from => 'lib/Getopt/Long/DescriptivePod.pm',
    requires          => {
        perl               => 5.008, # open \$scalar, io-layer?
        Carp               => 0, # perl dist
        English            => 0, # perl dist
        'Params::Validate' => 0,
        'Sub::Exporter'    => 0,
    },
    build_requires => {
        'Test::NoWarnings'          => 0,
        'Test::Exception'           => 0,
        'Test::Differences'         => 0,
        'Getopt::Long::Descriptive' => 0,
        'Test::More'                => 0, # dist Test-Simple
    },
    recommends => {
        # build
        'Test::Pod'           => '1.14',
        'Test::Pod::Coverage' => '1.04',
    },
    create_makefile_pl   => 'traditional',
    recursive_test_files => 0,
    add_to_cleanup       => [ qw(
        META.yml *.bak *.gz Makefile.PL
    ) ],
)->create_build_script;
