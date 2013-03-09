#use Test::Most;
use Devel::StackTrace::Always boop => { foo => 1, boo => 2, roo => 3 };
#use Carp::Always;

#die "oops";
#bop();

sub1();
sub sub1 { sub2() }
sub sub2 { sub3() }
sub sub3 { sub4() }
sub sub4 { sub5() }
sub sub5 { die "oops" }

#pass "yay";

#done_testing;
