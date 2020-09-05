package Input;

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
 Set the directory path to the node.dmp/names.dmp. : 
EOS

    #最後の改行は取り除く
    foreach($text1,$text2){chomp($_);}

    print $text1;
    my $flag = 'false';
    my $ansA = '';
    do{
    	$ansA = <STDIN>; #y or n;
    	chomp($ansA);

    	if($ansA eq 'y'){
    		$flag = 'true';

    	}elsif($ansA eq 'n'){
    		$flag = 'true';
    		#taxdmp.zipをダウンロード/解凍して
    		#node.dmp/names.dmpを./data直下に保存する.
	        print " downloading now...\n" ;
    		DownloadUtils::download();
    
    	}else{
    		print $text1;
    	}

    }while($flag eq 'false');

    #set the path to the node.dmp/names.dmp
    #&set_data()でセットした場合は./data直下
    my $dir='';
    if($ansA eq 'n'){
        $dir = './data';
    }else{
        my $flag2 = 'false';
        while($flag2 eq 'false'){
            print $text2;
            $dir = <STDIN>;
            chomp $dir;
            print "\n";

            if ($dir=~/.+\/$/ || $dir=~/.+\\$/){
                $dir =~s/^(.+).{1}$/$1/;
            }

            if(-f "${dir}/nodes.dmp" && -f "${dir}/names.dmp"){
                $flag2 = 'true';
                print " OK.\n\n";
            }else{
                print "\n";
                print " Error\n";
                print " Verify that the correct directory path are given.\n" ;
                print "\n";
            }
        }
    }

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
 ==========================================================
 input your file that describes your uniqueID & TaxonomyID

   Example : 
   --------------------
   AAA00001.1	112233
   AAB00002.1	112234
   ...
   --------------------

 Input your filename :  
EOS

my $text2 = <<'EOS';

 =========================================
 Select the delimiter you use in your file
 In this example case, the delimiter is 1 .

  1.  Tab
  2.  , 

 Select the number : 
EOS
    foreach($text1,$text2){chomp($_);}

    my $inputfile='';
    my $flag='false';
    while($flag eq 'false'){
        print $text1;
        $inputfile = <STDIN>;
        chomp $inputfile;
        if(-f $inputfile){
            $flag='true';
            print "\n" ;
            print " OK.\n\n";
        }else{
            print "\n";
            print " Error\n";
            print " Verify that correct path to the file is given.\n";
        }
    }

    my $delimiter = '';
    $flag = 'false'; 

    do{
        print $text2;
    	my $d = <STDIN>; #1~3
    	if($d == 1){
    		$flag = 'true';
    		$delimiter = "\t" ;

    	}elsif($d == 2){
    		$flag = 'true';
    		$delimiter = "," ;

    	}
    }while($flag eq 'false');

    return $inputfile,$delimiter ;

}

sub taxid_outfile {

=pod

    Description
    ------------
    全階層をtaxidで出力した結果を出力するファイル名

    Return
    ------
    $taxid_outfile : 全階層をtaxidで出力した結果を出力するファイル名

=cut

my $text1 =<<'EOS';


 Enter the output filename :  
EOS

my $text2 =<<'EOS';

 input OK.

EOS


    chomp($text1) ;
    print $text1;
    my $taxid_outfile = <STDIN>;
    my $flag = 'false';

    do{
    	chomp($taxid_outfile);
    	if($taxid_outfile eq ''){
            #re-loop
    	}else{
    		$flag = 'true' ;
            print $text2 ;
    	}

    }while($flag eq 'false');

    #flush
    $|=1;
    print "\n";
    print "\n";
    print " running..." ;
    $|=0;

    return $taxid_outfile;

}

sub isToSciname {
    
=pod
    Description
    ------------
    taxidを学名に変換して出力するかどうかを判断する.

    Return
    ------
    $bool : taxidを学名に変換して出力する場合true,しない場合はfalse

=cut

my $text1 =<<'EOS';

 ==================================================================

 Each TaxonomyID can be converted to Scientific name.
 Do you want to do that? (create new file) [y/n] :  
EOS

    chomp($text1);

    my $flag = 'false'; #to confirm the input-value
    my $bool = 'false';

    while($flag eq 'false'){
        print $text1 ;
    	my $in = <STDIN>; 
    	chomp($in);

    	if($in eq 'y'){
            $flag = 'true';
            $bool = 'true';
    	}elsif($in eq 'n'){
            $flag = 'true';
            $bool = 'false';
        }else{
            #loop
    	}
    }
    
    return $bool;
}

sub ask_update {

my $text =<<'EOS';


 ========================================
 Your input file includes old taxonomyID.

 Do you want to update them and run again?[y/n] : 
EOS

    chomp $text ;
    my $flag='false';
    my $ret_ans = '';
    while($flag eq 'false'){
        print $text;
        my $answer = <STDIN>;
        chomp $answer;

        if($answer eq 'y'){
            $flag='true';
            $ret_ans = 'true';
        }elsif($answer eq 'n'){
            $flag='true';
            $ret_ans = 'false';
        }else{
            #loop
        }
    }

    #flush
    $|=1;
    print "\n";
    print " running..." ;
    $|=0;

    return $ret_ans;

}


sub taxon_outfile {
=pod
    Description
    -----------
    taxonomyID|学名をtaxon|学名に変換する関数

    Returns
    -------
    $out_file_name : Descriptionで示した内容を出力するファイル名.

=cut

my $text1 =<<'EOS';

 Enter the output filename : 
EOS


my $text2 =<<'EOS';

 input OK.

EOS

    foreach($text1,$text2){chomp($_);}

	my $flag='false';
    my $out_file_name = '' ;
    while($flag eq 'false'){

        print $text1;
	    $out_file_name 	= <STDIN>;
	    chomp($out_file_name);

        if($out_file_name ne ''){
            $flag='true';
            print $text2;
        }else{
            #loop
        }
    }

    #flush
    $|=1;
    print "\n";
    print " running..." ;
    $|=0;

    return $out_file_name;
}


1;
