#use Test::Most;
use Devel::StackTrace::Always ignore => [qw/sub2 sub4/];

sub1();
sub sub1 { sub2() }
sub sub2 { sub3() }
sub sub3 { sub4() }
sub sub4 { sub5() }
sub sub5 { die "oops" }

#pass "yay";

#done_testing;
