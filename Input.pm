package input;

use strict;
use warnings;
use DownloadUtils;

sub set_data {
=pod
    Description
    -----------
    node.dmpおよびnames.dmpを配置したディレクトリへのパスを返す.

    Return
    ------
    $dir : node.dmpおよびnames.dmpを配置したディレクトリへのパス

=cut

my $text1 = <<'EOS';

 Do you have node.dmp and names.dmp? [y/n] : 
EOS

my $text2 = <<'EOS';

 =======================================
 Set the path to the node.dmp/names.dmp. : 
EOS

    print $text1;
    my $flag = 'false';
    my $dir  = '';
    do{
    	my $ansA = <STDIN>; #y or n;
    	chomp($ansA);
    	if($ansA eq 'y'){
    		$flag = 'true';
            print $text2;
    		$dir = <STDIN>;
            chomp $dir;
    		print "\n";

    	}elsif($ansA eq 'n'){
    		$flag = 'true';
    		#taxdmp.zipをダウンロード/解凍して
    		#node.dmp/names.dmpを./data直下に保存する.
    		DownloadUtils::download();
    
    	}else{
    		print $text1;
    	}

    }while($flag eq 'false');

    return $dir;

}

sub input_file {
=pod
    Description
    -----------
    AccessionIDとTaxonomyIDをデリミタで区切られたファイルのパスを
    セットする.
    当該ファイルで使用しているデリミタも選択する.

    Return
    ----------
    $inputfile : AccessionIDとTaxonomyIDがデリミタで区切られたファイルのパスを
                  返す.
    
    $delimiter : $inputfileで使用しているデリミタ

=cut

my $text1 = <<'EOS';
 =======================================================
 input your file that describes AccessionID & TaxonomyID

   Example : 
   --------------------
   AAA00001.1	112233
   AAB00002.1	112234
   ...
   --------------------

 your file :  
EOS

my $text2 = <<'EOS';

 =========================================
 Select the delimiter you use in your file
 In this example case, the delimiter is 1 .

  1.  Tab
  2.  , 
  3.  space

 Select the number : 
EOS

    print $text1;
    my $inputfile = <STDIN>;
    chomp $inputfile;
    print $text2;

    my $delimiter = '';
    $flag = 'false';

    do{
    	my $d = <STDIN>; #1~3
    	if($d == 1){
    		$flag = 'true';
    		$delimiter = "\t" ;

    	}elsif($d == 2){
    		$flag = 'true';
    		$delimiter = "," ;

    	}elsif($d == 3){
    		$flag = 'true';
    		$delimiter = " " ;

    	}
    }while($flag eq 'false');

    return $inputfile　,$delimiter ;

}

1;