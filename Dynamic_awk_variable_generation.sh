#!/bin/bash
echo "Custom Attributes generation process started at `date`" 

#Its static, but preferable to obtain dinamycally
pathtemp=`dirname $0`
absolute_path_awk=`readlink -e $pathtemp/awk_name.txt`
absolute_path_script=`echo $absolute_path_awk | rev | cut -d'/' -f3- | rev`
echo "absolute "$absolute_path_script
echo "pathtemp "$pathtemp

awk_name=`cat $pathtemp/awk_name.txt`
unlink awk_name.txt

path=$absolute_path_script/$awk_name #for AWK

echo "Inquiry Generation process started on location $path"

mkdir -p $path/temp
output_path=$path/temp

#Input path
path=$path/Input

success()
{
if [ $1 -ne 0 ]
then 
echo "something is wrong"
exit 1
else
echo "Successfull !!!!"
fi
}


part1=$output_path/Inquiry_Attribute_part_1.csv
part2=$output_path/Inquiry_Attribute_part_2.csv
part3=$output_path/Inquiry_Attribute_part_3.csv
product_tag=$output_path/Inquiry_Attribute_part_4.csv
ioi=$path"/Ioi.csv"
account_input=$path"/Account.csv"
inquiry_input=$path"/Inquiry.csv"




###########Checking directory path##############
if [ -d "$path" ]
then echo "is Directory"
else
echo "not a directory"
exit 1
fi

############Checking input files presence##################
ls $inquiry_input
success $?
ls $ioi
success $?
ls $account_input
success $?



################################################################## CALL TO R SCRIPT #####################################################################################

## Path to script files
echo "Inquiry Attributes generation process started at `date`" 
#Rscript /home/ubuntu/data/SBI_CC_PROJECT/Inquiry_Attributes.r "$DIR"

echo "Account Attributes generation process started at `date`" 
#Rscript /home/ubuntu/data/SBI_CC_PROJECT/Account_Attributes.r "$DIR"

################################################################## CALL TO R SCRIPT ENDS #####################################################################################


################################################################## INQUIRY P1 AWK VARAIBLES STARTS HERE #####################################################################################

#### Checking If retro pr date is present in inquiry file column 31.
#### If Retro PR date is present then consider it or extract inquiry date from credt_rpt_id column.

	retro_pr_dt=`awk -F'|' 'NR == 2 {print $31};' $inquiry_input` 		# reading 2nd row 31st column of inquiry file
	temp="${retro_pr_dt//\"}"  							# replace quotes from retro pr date
	retro_pr_dt=$temp
	echo ${#retro_pr_dt} 

if [ ${#retro_pr_dt} -gt 2 ]
then
	retro_pr_dt=`echo $retro_pr_dt | awk '{print substr($1,7,4)" "substr($1,4,2)" "substr($1,1,2)" 0 0 0"}'` # create date 
	echo "Running process for Retro PR Date $retro_pr_dt"
else
	echo "Retro PR Date column is Null"
	echo "So Considering inquiry date as retro-pr-date"
	retro_pr_dt=`awk -F'|' '{gsub("\"","",$1)} NR == 2 {print substr($1,5,6)}' $inquiry_input`
	retro_pr_dt=`echo $retro_pr_dt | awk '{print "20"substr($1,1,2)" "substr($1,3,2)" "substr($1,5,2)" 0 0 0"}'`
	echo "Running process for Retro PR Date $retro_pr_dt"
fi





								########################KOTAK##############################
#echo CREDT-RPT-ID|NO_OF_TRADES|TOTAL_CURRENT_BALANCE|TOTAL_AMNT_OVERDUE|TOTAL_OUTSTANDING_BALANCE|ACTIVE_ACCOUNT|ALL_TYPES_TRADES.Active|SETTLED_POST_WRITE_OFF|DISBURSED.AMT.HIGH.CREDIT.OPEN|DISBURSED.AMT.HIGH.CREDIT.CLOSED|TRADESWITHIN_6MNTHS|BAD_TO_GOOD_6MNTH|PL_CLOSED_6_MONTHS|PL_CLOSED_12_MONTHS|PL_CLOSED_3_YEARS_CLEAN|PL_CLOSED_3_YEARS_ONE_PMT_MISS|PL_AUTO_DPD_CURR_ZERO|DEL_TRADES|DEL_TRADES_CHARGE_OFF|DEL_TRADES_BAL|DEL_TRADES_CHARGE_OFF_BAL|PL_6_MONTHS|PL_12_MONTHS|PL_AMT_6_MONTHS|PL_AMT_12_MONTHS|AL_6_MONTHS|AL_12_MONTHS|AL_AMT_6_MONTHS|AL_AMT_12_MONTHS|OT_6_MONTHS|OT_12_MONTHS|OT_AMT_6_MONTHS|OT_AMT_12_MONTHS|CC_6_MONTHS|CC_12_MONTHS|CC_AMT_6_MONTHS|CC_AMT_12_MONTHS|PSU FLAG" > "$part1"

#awk -F'|' '{$999=$31;$68=$16;$66=$31;$62=$17;$61=$16;$63=$13;$64=$31;$664=$31;gsub("\"","",$12);gsub("\"|-","",$68);$68=substr($68,5,4)" "substr($68,3,2)" "substr($68,1,2)" 0 0 0";$57=gsub("\"","",$11);gsub("\"","",$62)gsub("-"," ",$62);$62=substr($62,7,4)" "substr($62,4,2)" "substr($62,1,2)" 0 0 0";gsub("\"","",$63)gsub("-"," ",$63);$63=substr($63,7,4)" "substr($63,4,2)" "substr($63,1,2)" 0 0 0";$51=retro_pr_date; gsub("\"","",$66);$66=substr($66,1,36);gsub("0|X|D","",$66);gsub("\"","",$64)gsub("X","",$64)gsub("D","",$64)gsub("0","",$64)gsub("\"","",$11)gsub("\"","",$15);gsub("\"","",$664)gsub("X","0",$664)gsub("D","0",$664)gsub("\"","",$11)gsub("\"","",$15);split($664,x,"[^1-9]+");gsub("\"","",$35);$54=substr($35,1,3);$55=substr($35,4,15);gsub("\"","",$61)gsub("-"," ",$61);$61=substr($61,7,4)" "substr($61,4,2)" "substr($61,1,2)" 0 0 0";$51=retro_pr_date; gsub("\"","",$19)gsub(",","",$19)gsub("\"","",$28)gsub(",","",$25)gsub("\"","",$25);gsub(",","",$22)gsub("\"","",$22);gsub(",","",$20)gsub("\"","",$20);gsub("\"","",$15);}NF>1{tt[$1] +=1}{{if((length($999)>0)) tcb[$1] +=$22; else tcb[$1]=tcb[$1];}}{{if((length($999)>0)) toa[$1] +=$25; else toa[$1]=toa[$1];}}{{if((($15=="Active")) && (length($999)>0)) tacb[$1] +=$22; else tacb[$1] +=0;}}{{if((($15=="Active"))&& (length($999)>0)) tot[$1] +=1; else tot[$1] +=0;}}{{if(($28=="Post (WO) Settled")) pwos[$1] +=1; else pwos[$1] +=0;}}{{if((($15=="Active")||($15=="Delinquent"))&&(length($999)>0)) thco[$1] +=$19; else thco[$1] +=0;}}{{if((($15=="Closed")||($15=="Written Off"))&&(length($999)>0))thcc[$1] +=$19; else thcc[$1] +=0;}}{{if(((mktime($51)-mktime($61))/86400)<181) tol6m[$1] +=1; else tol6m[$1] +=0;}}{{if(($28=="Post (WO) Settled")||($28=="Settled")) as[$1] +=1; else as[$1] +=0;}}{if($54=="S04" && (match($55,"S13")||match($55,"S19")||match($55,"S06")||match($55,"S18")) && (((mktime($51)-mktime($63))/86400)<181)) scil6m[$1] +=1; else scil6m[$1] +=0; }{if($54=="S07" && $11=="Personal Loan" && (((mktime($51)-mktime($62))/86400)<181)) plcil6m[$1] +=1; else plcil6m[$1] +=0; }{if($54=="S07" && $11=="Personal Loan" && (((mktime($51)-mktime($62))/86400)<366)) plcil12m[$1] +=1; else plcil12m[$1] +=0;}{if (($11=="Personal Loan")&&(length($64)==0)&&($15=="Closed") && (((mktime($51)-mktime($62))/86400)<1096)) plcl3ycd[$1] +=1; else plcl3ycd[$1] +=0;}{if (($11=="Personal Loan")&&(length((match($664,/(0[1-2][0-9])/)-1)/3)==1||length((match($664,/(00[1-9])/)-1)/3)==1)&&($15=="Closed") && (x[3]==0) && (((mktime($51)-mktime($62))/86400)<1096)) plcl3yopm[$1] +=1; else plcl3yopm[$1] +=0;}{{if((((mktime($51)-mktime($61))/86400)<730)&&($11=="Personal Loan"||$11=="Auto Loan (Personal)")&&(length($66)==0)) pl_2y_dpd_clean[$1] +=1; else pl_2y_dpd_clean[$1] +=0;}}{if($15=="Written Off") no_del_charge_off[$1] +=1; else no_del_charge_off[$1] +=0;}{if($15=="Delinquent") no_del_non_charge_off[$1] +=1; else no_del_non_charge_off[$1] +=0;}{if($15=="Delinquent") no_del_trd_os_bal_non_chrg_off[$1] +=$22; else no_del_trd_os_bal_non_chrg_off[$1] +=0;}{if($15=="Written Off") no_del_trd_os_bal_chrg_off[$1] +=$22; else no_del_trd_os_bal_chrg_off[$1] +=0;}{if($11=="Personal Loan" && (((mktime($51)-mktime($68))/86400)<181)) no_tm_pl_tk_6m[$1] +=1; else no_tm_pl_tk_6m[$1] +=0;}{if($11=="Personal Loan" && (((mktime($51)-mktime($68))/86400)<366)) no_tm_pl_tk_12m[$1] +=1; else no_tm_pl_tk_12m[$1] +=0; }{if($11=="Personal Loan" && (((mktime($51)-mktime($68))/86400)<181)) amt_pl_tk_6m[$1] +=$20; else amt_pl_tk_6m[$1] +=0; }{if($11=="Personal Loan" && (((mktime($51)-mktime($68))/86400)<366)) amt_pl_tk_12m[$1] +=$20; else amt_pl_tk_12m[$1] +=0; }{if($11=="Auto Loan (Personal)" && (((mktime($51)-mktime($68))/86400)<181)) no_tm_al_tk_6m[$1] +=1; else no_tm_al_tk_6m[$1] +=0;}{if($11=="Auto Loan (Personal)" && (((mktime($51)-mktime($68))/86400)<366)) no_tm_al_tk_12m[$1] +=1; else no_tm_al_tk_12m[$1] +=0; }{if($11=="Auto Loan (Personal)" && (((mktime($51)-mktime($68))/86400)<181)) amt_al_tk_6m[$1] +=$20; else amt_al_tk_6m[$1] +=0; }{if($11=="Auto Loan (Personal)" && (((mktime($51)-mktime($68))/86400)<366)) amt_al_tk_12m[$1] +=$20; else amt_al_tk_12m[$1] +=0; }{if($11=="Other" && (((mktime($51)-mktime($68))/86400)<181)) no_tm_ot_tk_6m[$1] +=1; else no_tm_ot_tk_6m[$1] +=0;}{if($11=="Other" && (((mktime($51)-mktime($68))/86400)<366)) no_tm_ot_tk_12m[$1] +=1; else no_tm_ot_tk_12m[$1] +=0;}{if($11=="Other" && (((mktime($51)-mktime($68))/86400)<181)) amt_ot_tk_6m[$1] +=$20; else amt_ot_tk_6m[$1] +=0; }{if($11=="Other" && (((mktime($51)-mktime($68))/86400)<366)) amt_ot_tk_12m[$1] +=$20; else amt_ot_tk_12m[$1] +=0; }{if($11=="Credit Card" && (((mktime($51)-mktime($68))/86400)<181)) no_tm_cc_tk_6m[$1] +=1; else no_tm_cc_tk_6m[$1] +=0;}{if($11=="Credit Card" && (((mktime($51)-mktime($68))/86400)<366)) no_tm_cc_tk_12m[$1] +=1; else no_tm_cc_tk_12m[$1] +=0; }{if($11=="Credit Card" && (((mktime($51)-mktime($68))/86400)<181)) amt_cc_tk_6m[$1] +=$20; else amt_cc_tk_6m[$1] +=0; } {if($11=="Credit Card" && (((mktime($51)-mktime($68))/86400)<366)) amt_cc_tk_12m[$1] +=$20; else amt_cc_tk_12m[$1] +=0; } {if($12=="NAB") psu_flg[$1] +=1; else psu_flg[$1] +=0;} END	{for(i in tt){print i"|"tt[i]"|"tcb[i]"|"toa[i]"|"tacb[i]"|"tot[i]"|"tot[i]"|"pwos[i]"|"thco[i]"|"thcc[i]"|"tol6m[i]"|"scil6m[i]"|"plcil6m[i]"|"plcil12m[i]"|"plcl3ycd[i]"|"plcl3yopm[i]"|"pl_2y_dpd_clean[i]"|"no_del_charge_off[i]"|"no_del_non_charge_off[i]"|"no_del_trd_os_bal_non_chrg_off[i]"|"no_del_trd_os_bal_chrg_off[i]"|"no_tm_pl_tk_6m[i]"|"no_tm_pl_tk_12m[i]"|"amt_pl_tk_6m[i]"|"amt_pl_tk_12m[i]"|"no_tm_al_tk_6m[i]"|"no_tm_al_tk_12m[i]"|"amt_al_tk_6m[i]"|"amt_al_tk_12m[i]"|"no_tm_ot_tk_6m[i]"|"no_tm_ot_tk_12m[i]"|"amt_ot_tk_6m[i]"|"amt_ot_tk_12m[i]"|"no_tm_cc_tk_6m[i]"|"no_tm_cc_tk_12m[i]"|"amt_cc_tk_6m[i]"|"amt_cc_tk_12m[i]"|" psu_flg[i]}}' retro_pr_date="$retro_pr_dt" "$account_input" >> "$part1"
								########################KOTAK##############################




echo "\"CREDT-RPT-ID\"|NO_OF_TRADES|TOTAL_CURRENT_BALANCE|TOTAL_AMNT_OVERDUE|TOTAL_OUTSTANDING_BALANCE|ACTIVE_ACCOUNT|ALL_TYPES_TRADES.Active|SETTLED_POST_WRITE_OFF|DISBURSED.AMT.HIGH.CREDIT.OPEN|DISBURSED.AMT.HIGH.CREDIT.CLOSED|TRADESWITHIN_6MNTHS|BAD_TO_GOOD_6MNTH|PL_CLOSED_6_MONTHS|PL_CLOSED_12_MONTHS|PL_CLOSED_3_YEARS_CLEAN|PL_CLOSED_3_YEARS_ONE_PMT_MISS|PL_AUTO_DPD_CURR_ZERO|DEL_TRADES|DEL_TRADES_CHARGE_OFF|DEL_TRADES_BAL|DEL_TRADES_CHARGE_OFF_BAL|PL_6_MONTHS|PL_12_MONTHS|PL_AMT_6_MONTHS|PL_AMT_12_MONTHS|PSU FLAG" > "$part1"
awk -F'|' '{$999=$31;$68=$16;$66=$31;$62=$17;$61=$16;$63=$13;$64=$31;$664=$31;gsub("\"","",$12);gsub("\"|-","",$68);$68=substr($68,5,4)" "substr($68,3,2)" "substr($68,1,2)" 0 0 0";$57=gsub("\"","",$11);gsub("\"","",$62)gsub("-"," ",$62);$62=substr($62,7,4)" "substr($62,4,2)" "substr($62,1,2)" 0 0 0";gsub("\"","",$63)gsub("-"," ",$63);$63=substr($63,7,4)" "substr($63,4,2)" "substr($63,1,2)" 0 0 0";$51=retro_pr_date; gsub("\"","",$66);$66=substr($66,1,36);gsub("0|X|D","",$66);gsub("\"","",$64)gsub("X","",$64)gsub("D","",$64)gsub("0","",$64)gsub("\"","",$11)gsub("\"","",$15);gsub("\"","",$664)gsub("X","0",$664)gsub("D","0",$664)gsub("\"","",$11)gsub("\"","",$15);split($664,x,"[^1-9]+");gsub("\"","",$35);$54=substr($35,1,3);$55=substr($35,4,15);gsub("\"","",$61)gsub("-"," ",$61);$61=substr($61,7,4)" "substr($61,4,2)" "substr($61,1,2)" 0 0 0";$51=retro_pr_date; gsub("\"","",$19)gsub(",","",$19)gsub("\"","",$28)gsub(",","",$25)gsub("\"","",$25);gsub(",","",$22)gsub("\"","",$22);gsub(",","",$20)gsub("\"","",$20);gsub("\"","",$15);}NF>1{tt[$1] +=1} {{if((length($999)>0)) tcb[$1] +=$22; else tcb[$1]=tcb[$1];}}{{if((length($999)>0)) toa[$1] +=$25; else toa[$1]=toa[$1];}}{{if((($15=="Active")) && (length($999)>0)) tacb[$1] +=$22; else tacb[$1] +=0;}}{{if((($15=="Active"))&& (length($999)>0)) tot[$1] +=1; else tot[$1] +=0;}}{{if(($28=="Post (WO) Settled")) pwos[$1] +=1; else pwos[$1] +=0;}}{{if((($15=="Active")||($15=="Delinquent"))&&(length($999)>0)) thco[$1] +=$19; else thco[$1] +=0;}}{{if((($15=="Closed")||($15=="Written Off"))&&(length($999)>0))thcc[$1] +=$19; else thcc[$1] +=0;}} {{if(((mktime($51)-mktime($61))/86400)<181) tol6m[$1] +=1; else tol6m[$1] +=0;}}{{if(($28=="Post (WO) Settled")||($28=="Settled")) as[$1] +=1; else as[$1] +=0;}}{if($54=="S04" && (match($55,"S13")||match($55,"S19")||match($55,"S06")||match($55,"S18")) && (((mktime($51)-mktime($63))/86400)<181)) scil6m[$1] +=1; else scil6m[$1] +=0; }{if($54=="S07" && $11=="Personal Loan" && (((mktime($51)-mktime($62))/86400)<181)) plcil6m[$1] +=1; else plcil6m[$1] +=0; }{if($54=="S07" && $11=="Personal Loan" && (((mktime($51)-mktime($62))/86400)<366)) plcil12m[$1] +=1; else plcil12m[$1] +=0;} {if (($11=="Personal Loan")&&(length($64)==0)&&($15=="Closed") && (((mktime($51)-mktime($62))/86400)<1096)) plcl3ycd[$1] +=1; else plcl3ycd[$1] +=0;} {if (($11=="Personal Loan")&&(length((match($664,/(0[1-2][0-9])/)-1)/3)==1||length((match($664,/(00[1-9])/)-1)/3)==1)&&($15=="Closed") && (x[3]==0) && (((mktime($51)-mktime($62))/86400)<1096)) plcl3yopm[$1] +=1; else plcl3yopm[$1] +=0;} {{if((((mktime($51)-mktime($61))/86400)<730)&&($11=="Personal Loan"||$11=="Auto Loan (Personal)")&&(length($66)==0)) pl_2y_dpd_clean[$1] +=1; else pl_2y_dpd_clean[$1] +=0;}} {if($15=="Written Off") no_del_charge_off[$1] +=1; else no_del_charge_off[$1] +=0;} {if($15=="Delinquent") no_del_non_charge_off[$1] +=1; else no_del_non_charge_off[$1] +=0;} {if($15=="Delinquent") no_del_trd_os_bal_non_chrg_off[$1] +=$22; else no_del_trd_os_bal_non_chrg_off[$1] +=0;} {if($15=="Written Off") no_del_trd_os_bal_chrg_off[$1] +=$22; else no_del_trd_os_bal_chrg_off[$1] +=0;} {if($11=="Personal Loan" && (((mktime($51)-mktime($68))/86400)<181)) no_tm_pl_tk_6m[$1] +=1; else no_tm_pl_tk_6m[$1] +=0;} {if($11=="Personal Loan" && (((mktime($51)-mktime($68))/86400)<366)) no_tm_pl_tk_12m[$1] +=1; else no_tm_pl_tk_12m[$1] +=0; }  {if($11=="Personal Loan" && (((mktime($51)-mktime($68))/86400)<181)) amt_pl_tk_6m[$1] +=$20; else amt_pl_tk_6m[$1] +=0; }{if($11=="Personal Loan" && (((mktime($51)-mktime($68))/86400)<366)) amt_pl_tk_12m[$1] +=$20; else amt_pl_tk_12m[$1] +=0; } {if($12=="NAB") psu_flg[$1] +=1; else psu_flg[$1] +=0;} END{for(i in tt){print i"|"tt[i]"|"tcb[i]"|"toa[i]"|"tacb[i]"|"tot[i]"|"tot[i]"|"pwos[i]"|"thco[i]"|"thcc[i]"|"tol6m[i]"|"scil6m[i]"|"plcil6m[i]"|"plcil12m[i]"|"plcl3ycd[i]"|"plcl3yopm[i]"|"pl_2y_dpd_clean[i]"|"no_del_charge_off[i]"|"no_del_non_charge_off[i]"|"no_del_trd_os_bal_non_chrg_off[i]"|"no_del_trd_os_bal_chrg_off[i]"|"no_tm_pl_tk_6m[i]"|"no_tm_pl_tk_12m[i]"|"amt_pl_tk_6m[i]"|"amt_pl_tk_12m[i]"|"psu_flg[i]}}' retro_pr_date="$retro_pr_dt" "$account_input" >> "$part1"


echo "\"CREDT-RPT-ID\"|MIN_TIME_OPEN_TRADE|MIN_TIME_ALL_TRADE|MIN_TIME_CC_ALL_TRADE|MIN_TIME_PL_ALL_TRADE|MAX_TIME_CC_ALL_TRADE|MAX_TIME_PL_ALL_TRADE|MAX_TIME_OPEN_TRADE|MAX_TIME_ALL_TRADE" > "$part2"
awk -F'|' '{$999=$31;$67=$16;gsub("\"|-","",$67);$67=substr($67,5,4)" "substr($67,3,2)" "substr($67,1,2)" 0 0 0";gsub("\"","",$15);$51=retro_pr_date;gsub("\"","",$11);}{{if(($15=="Active")) ayot[$1] =ayot[$1]","((mktime($51)-mktime($67))/86400); else ayot[$1] =ayot[$1];}}{{ ayat[$1] =ayat[$1]","((mktime($51)-mktime($67))/86400)}}{{if(($11=="Credit Card") && (length($999)>0)) ycca[$1] =ycca[$1]","((mktime($51)-mktime($67))/86400); else ycca[$1] =ycca[$1];}}{{if(($11=="Personal Loan")) ypla[$1] =ypla[$1]","((mktime($51)-mktime($67))/86400); else ypla[$1] =ypla[$1];}} {{if(($11=="Credit Card") && (length($16)>0) && (length($999)>0)) occa[$1] =occa[$1]",-"((mktime($51)-mktime($67))/86400); else occa[$1] =occa[$1];}} {{if(($11=="Personal Loan") && (length($16)>0)) opla[$1] =opla[$1]",-"((mktime($51)-mktime($67))/86400); else opla[$1] =opla[$1];}}{{if(($15=="Active") && (length($16)>0)) opt[$1] =opt[$1]",-"((mktime($51)-mktime($67))/86400); else opt[$1] =opt[$1];}}{{ if(length($16)>0) oldtest_trd[$1] =oldtest_trd[$1]",-"((mktime($51)-mktime($67))/86400); else oldtest_trd[$1] = oldtest_trd[$1]}} END{for(i in ayot){split(ayot[i],z1,",");split(ayat[i],z2,",");split(ycca[i],z3,",");split(ypla[i],z4,",");split(occa[i],z5,",");split(opla[i],z6,",");split(opt[i],z7,",");split(oldtest_trd[i],z8,",");asort(z1);asort(z2);asort(z3);asort(z4);asort(z5);asort(z6);asort(z7);asort(z8);print i"|"z1[2]"|"z2[2]"|"z3[2]"|"z4[2]"|"(z5[2]*-1)"|"(z6[2]*-1)"|"(z7[2]*-1)"|"(z8[2]*-1)}}' retro_pr_date="$retro_pr_dt" "$account_input" >> "$part2"


echo "\"CREDT-RPT-ID\"|PL_Inquiries_6mnth|Inquiries_6mnth" > "$part3"
awk -F '|' '{gsub("\"","",$7);gsub("\"","",$5)gsub("-"," ",$5);$61=substr($5,7,4)" "substr($5,4,2)" "substr($5,1,2)" 0 0 0";$51=retro_pr_date}NF>1{a[$1] +=1}{if($7=="PERSONAL LOAN" && (((mktime($51)-mktime($61))/86400)<181)) plel6m[$1] +=1; else plel6m[$1] +=0; }{{if((((mktime($51)-mktime($61))/86400)<181)) el6m[$1] +=1; else el6m[$1] +=0;}}END{for(i in a){print i"|"plel6m[i]"|"el6m[i]}}' retro_pr_date="$retro_pr_dt" "$ioi" >> "$part3"

################################################################## INQUIRY P1 AWK VARAIBLES STARTS HERE #####################################################################################

## PRODUCT TAG VARIABLES

echo "\"CREDT-RPT-ID\"|Active_trades_Credit_card|Active_trades_Personal_loan|Active_trades_Auto_loan|Active_trades_Housing_loan|Active_trades_Gold_loan|Active_trades_other_loans|Active_Current_bal_Credit_card|Active_Current_bal_Personal_loan|Active_Current_bal_Auto_loan|Active_Current_bal_Housing_loan|Active_Current_bal_Gold_loan|Active_Current_bal_other_loans|Delinquent_trades_Credit_card|Delinquent_trades_Personal_loan|Delinquent_trades_Auto_loan|Delinquent_trades_Housing_loan|Delinquent_trades_Gold_loan|Delinquent_trades_other_loans|Delinquent_Current_bal_Credit_card|Delinquent_Current_bal_Personal_loan|Delinquent_Current_bal_Auto_loan|Delinquent_Current_bal_Housing_loan|Delinquent_Current_bal_Gold_loan|Delinquent_Current_bal_other_loans|Written_off_trades_Credit_card|Written_off_trades_Personal_loan|Written_off_trades_Auto_loan|Written_off_trades_Housing_loan|Written_off_trades_Gold_loan|Written_off_trades_other_loans|Written_off_Current_bal_Credit_card|Written_off_Current_bal_Personal_loan|Written_off_Current_bal_Auto_loan|Written_off_Current_bal_Housing_loan|Written_off_Current_bal_Gold_loan|Written_off_Current_bal_other_loans" > $product_tag 

awk -F'|' '{$999=$31;gsub("\"","",$11);gsub("\"","",$15);gsub(",","",$22)gsub("\"","",$22);}  NR>1{a[$1] +=1}
{{if((length($999)>0) && ($11=="Credit Card") && (($15=="Active"))) tta_cc[$1] +=1; else tta_cc[$1] +=0;}}
{{if((length($999)>0) && ($11=="Personal Loan") && (($15=="Active"))) tta_pl[$1] +=1; else tta_pl[$1] +=0;}}
{{if((length($999)>0) && ($11=="Auto Loan (Personal)") && (($15=="Active"))) tta_al[$1] +=1; else tta_al[$1] +=0;}}
{{if((length($999)>0) && ($11=="Housing Loan") && (($15=="Active"))) tta_hl[$1] +=1; else tta_hl[$1] +=0;}}
{{if((length($999)>0) && ($11=="Gold Loan") && (($15=="Active"))) tta_gl[$1] +=1; else tta_gl[$1] +=0;}}
{{if((length($999)>0) && (($11!="Gold Loan")&&($11!="Credit Card")&&($11!="Personal Loan")&&($11!="Auto Loan (Personal)")&&($11!="Housing Loan")) && (($15=="Active"))) tta_ot[$1] +=1; else tta_ot[$1] +=0;}}
{{if((length($999)>0) && ($11=="Credit Card") && (($15=="Active"))) cba_cc[$1] +=$22; else cba_cc[$1] +=0;}}
{{if((length($999)>0) && ($11=="Personal Loan") && (($15=="Active"))) cba_pl[$1] +=$22; else cba_pl[$1] +=0;}}
{{if((length($999)>0) && ($11=="Auto Loan (Personal)") && (($15=="Active"))) cba_al[$1] +=$22; else cba_al[$1] +=0;}}
{{if((length($999)>0) && ($11=="Housing Loan") && (($15=="Active"))) cba_hl[$1] +=$22; else cba_hl[$1] +=0;}}
{{if((length($999)>0) && ($11=="Gold Loan") && (($15=="Active"))) cba_gl[$1] +=$22; else cba_gl[$1] +=0;}}
{{if((length($999)>0) && (($11!="Gold Loan")&&($11!="Credit Card")&&($11!="Personal Loan")&&($11!="Auto Loan (Personal)")&&($11!="Housing Loan")) && (($15=="Active"))) cba_ot[$1] +=$22; else cba_ot[$1] +=0;}}
{{if((length($999)>0) && ($11=="Credit Card") && (($15=="Delinquent"))) ttd_cc[$1] +=1; else ttd_cc[$1] +=0;}}
{{if((length($999)>0) && ($11=="Personal Loan") && (($15=="Delinquent"))) ttd_pl[$1] +=1; else ttd_pl[$1] +=0;}}
{{if((length($999)>0) && ($11=="Auto Loan (Personal)") && (($15=="Delinquent"))) ttd_al[$1] +=1; else ttd_al[$1] +=0;}}
{{if((length($999)>0) && ($11=="Housing Loan") && (($15=="Delinquent"))) ttd_hl[$1] +=1; else ttd_hl[$1] +=0;}}
{{if((length($999)>0) && ($11=="Gold Loan") && (($15=="Delinquent"))) ttd_gl[$1] +=1; else ttd_gl[$1] +=0;}}
{{if((length($999)>0) && (($11!="Gold Loan")&&($11!="Credit Card")&&($11!="Personal Loan")&&($11!="Auto Loan (Personal)")&&($11!="Housing Loan")) && (($15=="Delinquent"))) ttd_ot[$1] +=1; else ttd_ot[$1] +=0;}}
{{if((length($999)>0) && ($11=="Credit Card") && (($15=="Delinquent"))) cbd_cc[$1] +=$22; else cbd_cc[$1] +=0;}}
{{if((length($999)>0) && ($11=="Personal Loan") && (($15=="Delinquent"))) cbd_pl[$1] +=$22; else cbd_pl[$1] +=0;}}
{{if((length($999)>0) && ($11=="Auto Loan (Personal)") && (($15=="Delinquent"))) cbd_al[$1] +=$22; else cbd_al[$1] +=0;}}
{{if((length($999)>0) && ($11=="Housing Loan") && (($15=="Delinquent"))) cbd_hl[$1] +=$22; else cbd_hl[$1] +=0;}}
{{if((length($999)>0) && ($11=="Gold Loan") && (($15=="Delinquent"))) cbd_gl[$1] +=$22; else cbd_gl[$1] +=0;}}
{{if((length($999)>0) && (($11!="Gold Loan")&&($11!="Credit Card")&&($11!="Personal Loan")&&($11!="Auto Loan (Personal)")&&($11!="Housing Loan")) && (($15=="Delinquent"))) cbd_ot[$1] +=$22; else cbd_ot[$1] +=0;}}
{{if((length($999)>0) && ($11=="Credit Card") && (($15=="Written Off"))) ttw_cc[$1] +=1; else ttw_cc[$1] +=0;}}
{{if((length($999)>0) && ($11=="Personal Loan") && (($15=="Written Off"))) ttw_pl[$1] +=1; else ttw_pl[$1] +=0;}}
{{if((length($999)>0) && ($11=="Auto Loan (Personal)") && (($15=="Written Off"))) ttw_al[$1] +=1; else ttw_al[$1] +=0;}}
{{if((length($999)>0) && ($11=="Housing Loan") && (($15=="Written Off"))) ttw_hl[$1] +=1; else ttw_hl[$1] +=0;}}
{{if((length($999)>0) && ($11=="Gold Loan") && (($15=="Written Off"))) ttw_gl[$1] +=1; else ttw_gl[$1] +=0;}}
{{if((length($999)>0) && (($11!="Gold Loan")&&($11!="Credit Card")&&($11!="Personal Loan")&&($11!="Auto Loan (Personal)")&&($11!="Housing Loan")) && (($15=="Written Off"))) ttw_ot[$1] +=1; else ttw_ot[$1] +=0;}}
{{if((length($999)>0) && ($11=="Credit Card") && (($15=="Written Off"))) cbw_cc[$1] +=$22; else cbw_cc[$1] +=0;}}
{{if((length($999)>0) && ($11=="Personal Loan") && (($15=="Written Off"))) cbw_pl[$1] +=$22; else cbw_pl[$1] +=0;}}
{{if((length($999)>0) && ($11=="Auto Loan (Personal)") && (($15=="Written Off"))) cbw_al[$1] +=$22; else cbw_al[$1] +=0;}}
{{if((length($999)>0) && ($11=="Housing Loan") && (($15=="Written Off"))) cbw_hl[$1] +=$22; else cbw_hl[$1] +=0;}}
{{if((length($999)>0) && ($11=="Gold Loan") && (($15=="Written Off"))) cbw_gl[$1] +=$22; else cbw_gl[$1] +=0;}}
{{if((length($999)>0) && (($11!="Gold Loan")&&($11!="Credit Card")&&($11!="Personal Loan")&&($11!="Auto Loan (Personal)")&&($11!="Housing Loan")) && (($15=="Written Off"))) cbw_ot[$1] +=$22; else cbw_ot[$1] +=0;}}
END{for(i in a){print i"|"tta_cc[i]"|"tta_pl[i]"|"tta_al[i]"|"tta_hl[i]"|"tta_gl[i]"|"tta_ot[i]"|"cba_cc[i]"|"cba_pl[i]"|"cba_al[i]"|"cba_hl[i]"|"cba_gl[i]"|"cba_ot[i]"|"ttd_cc[i]"|"ttd_pl[i]"|"ttd_al[i]"|"ttd_hl[i]"|"ttd_gl[i]"|"ttd_ot[i]"|"cbd_cc[i]"|"cbd_pl[i]"|"cbd_al[i]"|"cbd_hl[i]"|"cbd_gl[i]"|"cbd_ot[i]"|"ttw_cc[i]"|"ttw_pl[i]"|"ttw_al[i]"|"ttw_hl[i]"|"ttw_gl[i]"|"ttw_ot[i]"|"cbw_cc[i]"|"cbw_pl[i]"|"cbw_al[i]"|"cbw_hl[i]"|"cbw_gl[i]"|"cbw_ot[i]}}' $account_input >> $product_tag 



echo "Process Completed!!!!!!!!!!!"

exit 1
################################################################################# JOIN SCRIPT########################################################################

echo "generation completed"

file1=$path/Inquiry_Attributes.csv
file2=$path/Inquiry_Attribute_part_1.csv
file3=$path/Inquiry_Attribute_part_2.csv
file4=$path/Inquiry_Attribute_part_3.csv
file5=$path/Inquiry_Attribute_part_4.csv

if [ -e $path/Inquiry_Attributes.csv ]
then
echo "present"

awk 'NR==1; !/CREDT-RPT-ID/' "$file1" > $path/temp && mv -f $path/temp "$file1"
awk 'NR==1; !/CREDT-RPT-ID/' "$file2" > $path/temp && mv -f $path/temp "$file2"
awk 'NR==1; !/CREDT-RPT-ID/' "$file3" > $path/temp && mv -f $path/temp "$file3"
awk 'NR==1; !/CREDT-RPT-ID/' "$file4" > $path/temp && mv -f $path/temp "$file4"
awk 'NR==1; !/CREDT-RPT-ID/' "$file5" > $path/temp && mv -f $path/temp "$file5"

 
awk 'NR == 1; NR > 1 {print $0 | "sort -n"}' "$file1" > $path/tmp
cat $path/tmp > "$file1"
awk 'NR == 1; NR > 1 {print $0 | "sort -n"}' "$file2" > $path/tmp
cat $path/tmp > "$file2"
awk 'NR == 1; NR > 1 {print $0 | "sort -n"}' "$file3" > $path/tmp
cat $path/tmp > "$file3"
awk 'NR == 1; NR > 1 {print $0 | "sort -n"}' "$file4" > $path/tmp
cat $path/tmp > "$file4"
awk 'NR == 1; NR > 1 {print $0 | "sort -n"}' "$file5" > $path/tmp
cat $path/tmp > "$file5"

join -t"|" -1 1 -a 1 -a1 -e "0" -o auto "$file1" "$file2" > $path/tmp
join -t"|" -1 1 -a 1 -a1 -e "0" -o auto "$path/tmp" "$file3" > $path/tmp1
join -t"|" -1 1 -a 1 -a1 -e "0" -o auto "$path/tmp1" "$file4" > $path/tmp2
join -t"|" -1 1 -a 1 -a1 -e "0" -o auto "$path/tmp2" "$file5" > $path/Inquiry_Attributes_Final.csv


else

awk 'NR==1; !/CREDT-RPT-ID/' "$file2" > $path/temp && mv -f $path/temp "$file2"
awk 'NR==1; !/CREDT-RPT-ID/' "$file3" > $path/temp && mv -f $path/temp "$file3"
awk 'NR==1; !/CREDT-RPT-ID/' "$file4" > $path/temp && mv -f $path/temp "$file4"
awk 'NR==1; !/CREDT-RPT-ID/' "$file5" > $path/temp && mv -f $path/temp "$file5"

 
awk 'NR == 1; NR > 1 {print $0 | "sort -n"}' "$file2" > $path/tmp
cat $path/tmp > "$file2"
awk 'NR == 1; NR > 1 {print $0 | "sort -n"}' "$file3" > $path/tmp
cat $path/tmp > "$file3"
awk 'NR == 1; NR > 1 {print $0 | "sort -n"}' "$file4" > $path/tmp
cat $path/tmp > "$file4"
awk 'NR == 1; NR > 1 {print $0 | "sort -n"}' "$file5" > $path/tmp
cat $path/tmp > "$file5"

join -t"|" -1 1 -a 1 -a1 -e "0" -o auto "$file2" "$file3" > $path/tmp
join -t"|" -1 1 -a 1 -a1 -e "0" -o auto "$path/tmp" "$file4" > $path/tmp1
join -t"|" -1 1 -a 1 -a1 -e "0" -o auto "$path/tmp1" "$file5" > $path/Inquiry_Attributes_semi_Final.csv


fi



################################################################################# JOIN SCRIPT########################################################################
