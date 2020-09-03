package a;

use strict;
use warnings;
use BimUtils;

sub new {
	my $class = shift ;
	my $self = { @_ } ;
	bless $self,$class;
	
	$self->init();
    
	return $self;
}

sub init {
	my $self = shift;

	$self->{accession_taxid_file} //= 'none';
	$self->{delimiter_of_accession_and_taxid} //='none';
	$self->{nodes_dmp_file} //='none';
	$self->{names_dmp_file} //='none';

	#更新前taxidが入力に含まれていた場合に値が追加される連想配列
	my %old_taxid_hash = ();
	$self->{old_taxid_hash} = \%old_taxid_hash;

	#入力ファイルに含まれるAccessionIDとtaxidを結びつけた連想配列
	$self->{ac_tx_hash} = BimUtils->hash_key_del_val(
		$self->{accession_taxid_file},
		$self->{delimiter_of_accession_and_taxid}
	);

	#指定の引数が入力されたかどうかの確認
	foreach my $t (keys %$self){
		if ($self->{$t} eq 'none'){
            #print "$t\n";
			print "Argument Error\n" ;
			exit;
		}
        
	}

}

1;