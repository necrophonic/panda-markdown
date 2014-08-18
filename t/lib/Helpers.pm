package Helpers;

use base qw|Exporter|;
use v5.10;
use Test::More;

our @EXPORT = qw|test_expected_tokens_list test_html_data_document|;

# Test the classes of returned tokens - doesn't test
# the content of any of the tokens.
sub test_expected_tokens_list {
	my ($tokens_got, $tokens_expected) = @_;

	if (scalar @$tokens_got != @$tokens_expected) {
		fail('Mismatch list! - got ['.@$tokens_got.'] expected ['.@$tokens_expected.']');
	}

	subtest 'expect tokens' => sub {
		plan tests => scalar @$tokens_expected;

		for (my $i=0;$i<@$tokens_expected;$i++)	{

			my $camel_token = ucfirst $tokens_expected->[$i];
			   $camel_token =~ s/_(\w)/\u$1/g;

			my $expected_class = 'Text::CaffeinatedMarkup::PullParser::'.$camel_token.'Token';
			is ref $tokens_got->[$i], $expected_class, ref($tokens_got->[$i]) ." == $expected_class";
		}
	};
}

sub test_html_data_document {
	my ($parser,$data) = @_;

	my ($in,$expected) = split /\n!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n/, $data;

	chomp $in;
	chomp $expected;	

	my $html = $parser->do($in);	

	my @in_a = split //, $html;
	my @ex_a = split //, $expected;

	subtest 'data document' => sub {		
		for (my $i=0; $i<@in_a; $i++) {
			if ($in_a[$i] ne $ex_a[$i]) {
				fail "Begin differ at char [".($i+1)."] (expected [$ex_a[$i]$ex_a[$i+1]$ex_a[$i+2]] -> got [$in_a[$i]$in_a[$i+1]$in_a[$i+2]])";
				print "Got:\n$html";
				return;
			}
		}
		ok 1;
	};
}

1;
