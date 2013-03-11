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

=pod



=cut

1;
