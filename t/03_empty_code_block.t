#perl -T

use strict;
use warnings;

use Test::More tests => 3 + 1;
use Test::NoWarnings;
use Test::Exception;

BEGIN {
    use_ok('Getopt::Long::DescriptivePOD');
}

lives_ok(
    sub {
        replace_pod({
            filename   => \q{},
            tag        => '=head1 USAGE',
            code_block => q{},
            on_verbose => sub {
                my $message = shift;
                $message =~ tr{\n}{ };
                diag($message);
                ok(1, $message);
            },
        });
    },
    'empty code block',
);
