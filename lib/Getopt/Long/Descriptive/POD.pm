package Getopt::Long::Descriptive::POD;

use strict;
use warnings;

our $VERSION = '0.01';

use Carp qw(confess);
use English qw(-no_match_vars $PROGRAM_NAME $OS_ERROR);
use Params::Validate qw(validate SCALAR SCALARREF CODEREF);
use Perl6::Export::Attrs;
require Tie::File;

sub replace_pod :Export(:DEFAULT) { ## no critic (ArgUnpacking)
    my %param_of = validate(
        @_,
        {
            filename          => { type => SCALAR | SCALARREF, default => $PROGRAM_NAME },
            encoding          => { type => SCALAR, optional => 1 },
            tag               => { regex => qr{ \A = \w }xms },
            before_code_block => { type => SCALAR, optional => 1 },
            code_block        => { type => SCALAR, optional => 1 },
            after_code_block  => { type => SCALAR, optional => 1 },
            indent            => { regex => qr{ \A \d+ \z }xms, default => 1 },
            on_fail           => { type => CODEREF, default => sub {confess @_} },
        },
    );

    BLOCK: for my $block ( qw(before_code_block after_code_block) ) {
        defined $param_of{block}
            or next BLOCK;
        $param_of{block} =~ m{ ^ = }xms
            and confess "A POD tag is not allowed in $block";
    }

    # after __END__ this handle is open
    {
        no warnings qw(once); ## no critic (ProhibitNoWarnings)
        () = close ::DATA;
    }

    # format block
    my ($code_block, $before_code_block, $after_code_block) = map {
        defined $_
        ? do {
            my $value = $_;
            $value =~ s{ \A \n* (.*?) \n* \z }{$1}xms;
            [ split m{ \n }xms, $value ];
        }
        : ();
    } @param_of{ qw(code_block before_code_block after_code_block ) };
    my @block = map { ## no critic (ComplexMappings)
        my $value = $_;
        $value =~ s{ \t }{ q{ } x $param_of{indent} }xmsge;
        $value =~ s{ \s+ \z }{}xms;
        $value;
    } (
        (
            $before_code_block
            ? (
                @{$before_code_block},
                q{},
            )
            : ()
        ),
        (
            $code_block
            ? do {
                map {
                    q{ } x $param_of{indent}
                    . $_;
                } @{$code_block};
            }
            : ()
        ),
        (
            $after_code_block
            ? (
                q{},
                @{$after_code_block}
            )
            : ()
        ),
    );

    # open file
    open my $file_handle, '+<', $param_of{filename} ## no critic (BriefOpen)
        or $param_of{on_fail}->( "Can not open '$param_of{filename}' $OS_ERROR" );
    if ( $param_of{encoding} ) {
        binmode $file_handle, $param_of{encoding}
            or $param_of{on_fail}->( "Can not binmode '$param_of{filename}' $OS_ERROR" );
    }
    tie ## no critic (Ties)
        my @content,
        'Tie::File',
        $file_handle,
        recsep => "\n";

    # replace POD
    my $is_found;
    my $index = 0;
    LINE: while ( $index < @content ) {
        my $line = $content[$index];
        if ( $is_found ) {
            if ( $line =~ m{ \A = \w }xms ) { # stop deleting on new tag
                $is_found = ();
                last LINE;
            }
            splice @content, $index, 1; # delete current line
        }
        if ( $line =~ m{ \A \Q$param_of{tag}\E \z }xms ) {
            $is_found++;
            splice @content, $index + 1, 0, q{}, @block, q{};
            $index += 1 + @block + 1;
        }
        $index++;
    }

    # close file
    untie @content;

    return;
}

# $Id$

1;

__END__

=pod

=head1 NAME

Getopt::Long::Descriptive::POD - write usage to POD

=head1 VERSION

0.01

=head1 SYNOPSIS

    use Getopt::Long::Descriptive;
    use Getopt::Long::Descriptive::POD;

    my ($opt, $usage) = describe_options(
        ...
    );
    
    if ( 'during development and test or ...' ) {
        replace_pod({
            tag        => '=head1 USAGE',
            code_block => $usage->text(),
        });
    }
    
=head1 EXAMPLE

Inside of this Distribution is a directory named example.
Run this *.pl files.

=head1 DESCRIPTION

C<Getopt::Long::Descriptive> is a excellent way
to write parameters and usage at the same time.

This module allows to write POD at the same time too.
The idea is to write the usage in the POD of the current script
during development or test.

=head1 SUBROUTINES/METHODS

=head2 sub replace_pod

Write the POD for your script and the POD.
Put a section into that POD
like C<=head1 USAGE>
or C<=head2 special usage for foo bar>.
No matter what is inside of that section
but no line looks like a POD tag beginning with C<=>.

A tabulator will be changed to "indent" whitespaces.
In code_block, before_code_block and after_code_block POD tags are not allowed. 

Run this subroutine and the usage is in the POD.

    replace_pod({
        tag => '=head1 USAGE',
        
        # optional (but not really) the usage as block of code
        code_block => $usage->text(),
        
        # optional text before that usage
        before_code_block => $multiline_text,
        
        # optional text after that usage
        after_code_block => $multiline_text,
        
        # optional if ident 1 is not enough
        indent => 4,
        
        # optional if confess ist not the expected behaviour
        on_fail => sub { do something like die or exit },
        
        # optional if some umlauts are in the usage
        # the default encoding is :raw
        encoding => { type => SCALAR, default => ':raw' },
        
        # for testing only
        # the default filename is $PROGRAM_NAME ($0)
        filename => { type => SCALAR | SCALARREF, default => $PROGRAM_NAME},
    });
    
=head1 DIAGNOSTICS

Confesses on false subroutine parameters.

The default is to confess on problems with reading/writing file.

=head1 CONFIGURATION AND ENVIRONMENT

nothing

=head1 DEPENDENCIES

Carp

English

L<Params::Validate|Params::Validate>

L<Perl6::Export::Attrs|Perl6::Export::Attrs>

L<Tie::File|Tie::File>

=head1 INCOMPATIBILITIES

not known

=head1 BUGS AND LIMITATIONS

C<__END__> in the script stops the compiler and opens the DATA file handle.
After call of C<replace_pod> the DATA file handle is closed.

Runs not on C<perl -e> calls or anything else with no real file name.

=head1 SEE ALSO

L<Getopt::Long::Descriptive|Getopt::Long::Descriptive>

=head1 AUTHOR

Steffen Winkler

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2011,
Steffen Winkler
C<< <steffenw at cpan.org> >>.
All rights reserved.

This module is free software;
you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut