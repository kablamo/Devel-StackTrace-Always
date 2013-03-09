package Devel::StackTrace::Always;
use Devel::StackTrace;
use Sub::Exporter -setup => {
    exports    => [bop => \&_build_bop],
    collectors => [qw/boop/],
};

sub _build_bop {
    my ($class, $name, $args) = @_;
    return sub { boop(%$args) };
}

sub bop {
    my %args = @_;
    print "args: \n";
    use DDP; p %args;
}

sub _die {
    my $trace = Devel::StackTrace->new;
    print "_die()\n";
    bop(boo => 1);
    while (my $frame = $trace->next_frame) {
        next if $frame->subroutine eq 'Devel::StackTrace::new';
        next if $frame->subroutine eq 'Devel::StackTrace::Always';
        next if $frame->subroutine eq 'Devel::StackTrace::Always::_die';
        print ">> " . $frame->as_string . "\n";
    }
};

my %OLD_SIG;

BEGIN {
  @OLD_SIG{qw(__DIE__ __WARN__)} = @SIG{qw(__DIE__ __WARN__)};
  $SIG{__DIE__}  = \&boop;
  $SIG{__WARN__} = \&_warn;
}

END {
  @SIG{qw(__DIE__ __WARN__)} = @OLD_SIG{qw(__DIE__ __WARN__)};
}

1;
