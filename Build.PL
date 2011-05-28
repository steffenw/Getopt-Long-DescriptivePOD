use strict;
use warnings;

use Module::Build;

my $is_ppm
    = (
        # install using ppm
        ! $ENV{AUTHOR_DIST}
        && eval 'require ActivePerl::PPM::Package'
    )
    || (
        # build ppm and ppd
        $ENV{AUTHOR_DIST}
        && $ENV{AUTHOR_DIST} eq 'ppm'
    );

Module::Build->new(
    module_name       => 'Getopt::Long::Descriptive::POD',
    license           => 'perl',
    dist_abstract     => 'Getopt::Long::Descriptive::POD - write usage to POD',
    dist_author       => 'Steffen Winkler <steffenw at cpan.org>',
    dist_version_from => 'lib/Getopt/Long/Descriptive/POD.pm',
    requires          => {
        perl                   => 5.008, # open \$scalar, io-layer?
        'File::Slurp'          => 0,
        'Params::Validate'     => 0,
        'Perl6::Export::Attrs' => 0,
        $is_ppm
        ? (
        )
        : (
            Carp    => 0, # perl dist
            English => 0, # perl dist
        )
    },
    build_requires => {
        'Test::NoWarnings'          => 0,
        'Test::Exception'           => 0,
        'Test::Differences'         => 0,
        'Getopt::Long::Descriptive' => 0,
        $is_ppm
        ? (
            'Test::Simple' => 0,
        )
        : (
            'Test::More' => 0, # dist Test-Simple
        )
    },
    recommends => {
        # build
        'Test::Pod'           => '1.14',
        'Test::Pod::Coverage' => '1.04',
    },
    create_makefile_pl   => 'traditional',
    recursive_test_files => 1,
    add_to_cleanup       => [ qw(
        META.yml *.bak *.gz Makefile.PL
    ) ],
)->create_build_script();
