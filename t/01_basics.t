#perl -T

use strict;
use warnings;

use Test::More tests => 5 + 1;
use Test::NoWarnings;
use Test::Exception;
use Test::Differences;

use Carp qw(confess);
use English qw(-no_macht_vars $OS_ERROR);

BEGIN {
    use_ok('Getopt::Long::Descriptive');
    use_ok('Getopt::Long::Descriptive::POD');
}

my $content = <<'EOT';
=head1 FOO
foo
=head1 USAGE
=head1 BAR
EOT

my ($opt, $usage);
lives_ok(
    sub {
        ($opt, $usage) = describe_options(
            'my-program %o <some-arg>',
            [ 'verbose|v',  'print extra stuff'            ],
            [],
            [ 'help',       'print usage message and exit' ],
        );
    },
    'describe_options',
);

lives_ok(
    sub {
        replace_pod({
            filename    => \$content,
            tag         => '=head1 USAGE',
            usage       => $usage->text(),
            indent      => 4,
        });
    },
    'replace_pod',
);

eq_or_diff($content, <<"EOT", 'usage in POD');
=head1 FOO
foo
=head1 USAGE

    my-program [-v] [long options...] <some-arg>
        -v --verbose   print extra stuff

        --help         print usage message and exit

=head1 BAR
EOT

;
