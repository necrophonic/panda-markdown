package PML::ImageToken;

use Moo;

has 'type'	 => ( is => 'ro', default => sub { 'IMAGE'} );

has 'src'	 => ( is => 'rw' );
has 'width'	 => ( is => 'rw' );
has 'height' => ( is => 'rw' );
has 'align'	 => ( is => 'rw', default => sub { '><' } );



1;
