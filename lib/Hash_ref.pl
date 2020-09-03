use strict;
use warnings;

use a;
=pod
my $taxobj = a->new(
		accession_taxid_file => "../data/inputA.txt",		# AccessionID/TaxonomyIDを記述したファイル
		delimiter_of_accession_and_taxid => " ",	# $inputfileで使用しているデリミタ
		nodes_dmp_file => "nodes.dmp",		# nodes.dmpのパス	  
		names_dmp_file => "names.dmp" 		# names.dmpのパス
	);

#print $taxobj->{ac_tx_hash}->{"BAB12390.1"};
=cut
sub func {
	print "a\n";
}

sub func2 {
	my $rf= shift;
	$rf->();
}

my $func = \&func;
func2($func);


=pod
my %hash = ('a'=>0,'b'=>1,'c'=>2);

my $self='';
$self  = {'p'=>1,'old_taxid_hash'=>\%hash};
$self->{old_taxid_hash}->{c} = 3;

foreach my $key (keys %{$$self{old_taxid_hash}}){
	print "$key\t$hash{$key}\n";
}

=cut





