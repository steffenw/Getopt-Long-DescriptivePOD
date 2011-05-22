#!perl

use strict;
use warnings;

use Test::More;
use Test::Differences;
use Carp qw(confess);
use Cwd qw(getcwd chdir);
use English qw(-no_match_vars $OS_ERROR $INPUT_RECORD_SEPARATOR);

$ENV{TEST_EXAMPLE} or plan(
    skip_all => 'Set $ENV{TEST_EXAMPLE} to run this test.'
);

plan(tests => 2);

my @data = (
    {
        test     => '01_example',
        path     => 'example',
        filename => '01_example.pl',
        params   => '-I../lib -T',
        result   => <<'EOT',
EOT
    },
);

for my $data (@data) {
    my $current_dir = getcwd();
    my $example_dir = "$current_dir/$data->{path}";
    chdir($example_dir);

    local $INPUT_RECORD_SEPARATOR = ();
    
    open my $file_handle, '<', $data->{filename}
        or confess "$data->{test} $OS_ERROR";
    my $old_content = <$file_handle>;
    () = close $file_handle;
    
    my $new_content = $old_content;
    $new_content =~ s{ \Q--help\E}{}xms;
    
    open $file_handle, '>', $data->{filename}
        or confess "$data->{test} $OS_ERROR";
    print {$file_handle} $new_content
        or confess "$data->{test} $OS_ERROR";
    close $file_handle
        or confess "$data->{test} $OS_ERROR";

    my $result = qx{perl $data->{params} $data->{filename} 2>&3};

    open $file_handle, '<', $data->{filename}
        or confess "$data->{test} $OS_ERROR";
    $new_content = <$file_handle>;
    () = close $file_handle;

    chdir($current_dir);
    eq_or_diff(
        $result,
        q{},
        "$data->{test} result",
    );
    eq_or_diff(
        $old_content,
        $new_content,
        "$data->{test} content",
    );
}