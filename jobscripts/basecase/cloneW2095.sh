#!/bin/bash

basecase='ctsm51c6_PPEn08ctsm51d023_2deg_GSWP3V1_Sparse400_SSP370-2091-2100_2000_step3'
envtype="W2095"
runtype="SASU"
stopn=80
prevtype="AD"
nyprev="21"

keithdir='/glade/work/oleson/PPE.n08_ctsm5.1.dev023/cime/scripts/'
newcase="PPEn08_"$envtype"_"$runtype
scripts='/glade/work/djk2120/PPEn08/cime/scripts/'
nlbase='/glade/u/home/djk2120/clm5ppe/nlbase/'
envdir=$envtype"/basecases/"
prevcase="PPEn08_"$envtype"_"$prevtype

cd $scripts
./create_clone --case $envdir$newcase --clone $keithdir$basecase --cime-output-root /glade/scratch/djk2120

cd $envdir$newcase
./case.setup

cp $nlbase$runtype".base" user_nl_clm.base
./xmlchange STOP_N=$stopn
./xmlchange JOB_QUEUE="economy"
./xmlchange DOUT_S="false"
./case.build

cp user_nl_clm.base user_nl_clm
echo -e "\nparamfile = '/glade/p/cgd/tss/people/oleson/modify_param/ctsm51_params.c210217_kwo.c210222.nc'" >> user_nl_clm
if [[ $runtype != "AD" ]];then
    scratch="/glade/scratch/djk2120/"$prevcase"/run/"
    suffix=".clm2.r.00"$nyprev"-01-01-00000.nc"
    restart=$scratch$prevcase$suffix
    echo "finidat = '"$restart"'" >> user_nl_clm
else
    echo "yes AD"
fi

if [[ $envtype == "nddep5" ]];then
    echo "stream_fldfilename_ndep = '/glade/p/cgd/tss/people/oleson/CLM5_ndep/fndep_p5_clm_hist_b.e21.BWHIST.f09_g17.CMIP6-historical-WACCM.ensmean_1849-2015_monthly_0.9x1.25_c180926.nc'">> user_nl_clm
fi

./case.submit