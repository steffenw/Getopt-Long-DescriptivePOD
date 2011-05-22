#!perl -T

use strict;
use warnings;

our $VERSION = 0;

use Carp qw(confess);
use English qw(-no_match_vars $OS_ERROR);
use Getopt::Long::Descriptive;
use Getopt::Long::Descriptive::POD;

my ($opt, $usage) = describe_options(
    'my-program %o <some-arg>',
    [ 'verbose|v',  'print extra stuff'            ],
    [],
    [ 'help',       'print usage message and exit' ],
);

replace_pod({
    tag              => '=head1 USAGE',
    before_codeblock => "before\ncodeblock",
    codeblock        => $usage->text(),
    after_codeblock  => "after\ncodeblock",
    indent           => 4,
});

# $Id: $

__END__

=head1 NAME
for test only
=head1 USAGE
=head1 DESCRIPTION
=head1 REQUIRED ARGUMENTS
=head1 OPTIONS
=head1 DIAGNOSTICS
=head1 EXIT STATUS
=head1 CONFIGURATION
=head1 DEPENDENCIES
=head1 INCOMPATIBILITIES
=head1 BUGS AND LIMITATIONS
=head1 AUTHOR
=head1 LICENSE AND COPYRIGHT
