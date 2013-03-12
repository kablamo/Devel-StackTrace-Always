package Devel::StackTrace::Always;
use Devel::StackTrace;

my @ignore;

sub import {
    my ($class, %args) = @_;
    @ignore = @{ $args{ignore} };
}

sub _die {
    my $trace = Devel::StackTrace->new;
    while (my $frame = $trace->next_frame) {
        next if $frame->subroutine eq 'Devel::StackTrace::new';
        next if $frame->subroutine eq 'Devel::StackTrace::Always';
        next if $frame->subroutine eq 'Devel::StackTrace::Always::_die';
        next if _skip_this_sub($frame);

        print "\t" . $frame->as_string . "\n";
    }
};

# returns 1 if we should skip this sub
# returns 0 if we should not skip this sub
sub _skip_this_sub {
    my $frame = shift or die;

    foreach my $regex (@ignore) {
        return 1 if $frame->subroutine =~ /$regex/;
    }

    return 0;
}

my %OLD_SIG;

BEGIN {
  @OLD_SIG{qw(__DIE__ __WARN__)} = @SIG{qw(__DIE__ __WARN__)};
  $SIG{__DIE__}  = \&_die;
  $SIG{__WARN__} = \&_warn;
}

END {
  @SIG{qw(__DIE__ __WARN__)} = @OLD_SIG{qw(__DIE__ __WARN__)};
}

=head1 SYNOPSIS

    use Devel::StackTrace::Always ignore => [qw/sharks bears/];

    wolves();

    sub wolves { sharks()    };
    sub sharks { bears()     };
    sub bears  { lions()     };
    sub lions  { snakes()    };
    sub snakes { die('boop') };

    # output looks like:
    boop at predators.pl line 9.
            main::snakes at predators.pl line 8
            main::lions at predators.pl line 7
            main::wolves at predators.pl line 3


=head1 DESCRIPTION

This module is inspired by Carp::Always.  It is meant as a debugging aid.   It
forces a script to print a stacktrace when warn()ing or die()ing.  

The advantage this module has over Carp::Always is that it allows the user to
filter items out of the stacktrace.  This is useful in larger applications
where stacktraces can get very long and where you often want to filter out
parts of a stacktrace.  For example a Plack application usually doesn't need
Plack to be part of the stacktrace.

=head1 MORE IDEAS

=over4

=item Figure out how to ignore stuff via the command line

=item Shorter module name (alias) for use on the command line

=item A more readable default stacktrace output

=item Configurable stacktrace output?

=item Colored output?

=item An easy way to toggle showing all stacktraces vs hiding ignored parts of the stack

=item Plugins on CPAN which ignore parts of the stack from certain applications?

For example Devel::StackTrace::Filter::Plack, Devel::StackTrace::Filter::Catalyst.  

=item Configuration files?

Allow setting configuration via a file.  Like Data::Printer does.

=item Split out some code into Devel::StackTrace::Filter?

Perhaps this should be 2 modules: Devel::StackTrace::Filter and
Devel::StackTrace::Always.  

=back

=cut

1;
