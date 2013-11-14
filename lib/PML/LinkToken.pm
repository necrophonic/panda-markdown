package PML::LinkToken;

use Moo;

has 'type'	=> ( is => 'ro', default => sub { 'LINK'} );
has 'url'	=> ( is => 'rw' );
has 'text'	=> ( is => 'rw' );

# Override text so that if it's not set or blank then
# we get the value of the url instead.
around text => sub {
	my ($orig, $self, $value) = @_;
	$self->{text} = $value if defined $value;
	return $self->{text} || $self->{url};
};


1;
