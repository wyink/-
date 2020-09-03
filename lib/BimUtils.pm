package BimUtils;

use strict;
use warnings;

sub hash_key_del_val {
    my ($self,$infile,$delimiter,$func) = @_ ;

=pod 
    Description
    -----------
    デリミタで区切られた左側をkey・右側をvalueとしたhashを返す

    Parameters
    ----------
    $infile :入力ファイル
    $delimiter : 使用するデリミタ（tabなど）

    Returns
    -------
    $hash_ref : keyはデリミタの左側、valueは右側の値

    example
    -------
    my $href = BimUtils->hash_key_del_val("3_viridi_taxid.txt","\t" );
    foreach my $key (keys %$href){
    	print "$key\t$href->{$key}\n";
    }

=cut

    #&func = \$func;
    my %hash = () ;
    open my $FH,"<",$infile or die "Can't open ${infile}\n";
    while(my $line=<$FH>){
        chomp $line;
        #&func;
        my ($key,$value) = split/${delimiter}/,$line;
        $hash{$key} = $value ;
    }
    close $FH;
    return \%hash;

}

1;
