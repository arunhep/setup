#!/bin/bash

if [ -z $CMSSW_BASE ]; then
    echo "======================================="
    echo "No CMS environment detected; stopping..."
    echo "======================================="
    exit 1
fi

source $CMSSW_BASE/src/LatinosSetup/Functions.sh

if [[ "$CMSSW_VERSION" == CMSSW_5_3_* ]]; then

    echo "======================================="
    echo "running with $CMSSW_VERSION - this is an 8 TeV setup!"
    echo "Current Time:" $(date)
    echo "checking out additional repositories; this could take a while ..."
    echo "======================================="

    echo " - Basic Code"

    github-addext latinos/WWAnalysis.git WWAnalysis 8TeV
    (
        cd WWAnalysis
        rm -r AnalysisStep/data/datacards/finalCards/
        rm -r AnalysisStep/data/datacards/HZZ4L/
        rm    TreeModifiers/interface/SuperMELABranchAdder.h
        rm    TreeModifiers/src/SuperMELABranchAdder.cc
        rm    AnalysisStep/plugins/SkimEvent4LSelector.cc
        rm    AnalysisStep/plugins/SkimEvent4LProducer.cc
    )
    github-addext latinos/HWWAnalysis.git HWWAnalysis

    github-addext latinos/HiggsAnalysis-HiggsToWW2Leptons.git HiggsAnalysis/HiggsToWW2Leptons For2011-October-21st-reload
    github-addext latinos/UserCode-MitPhysics-data-ElectronMVAWeights.git HiggsAnalysis/HiggsToWW2Leptons/data/ElectronMVAWeights HWW_V1
    github-addext latinos/UserCode-sixie-Muon-MuonAnalysisTools.git Muon/MuonAnalysisTools V00-00-10

    github-addext latinos/UserCode-EGamma-EGammaAnalysisTools.git EGamma/EGammaAnalysisTools V00-00-30
    (
        cd EGamma/EGammaAnalysisTools
        sed 's#EGamma/EGammaAnalysisTools/data/Electrons_BDT#WWAnalysis/AnalysisStep/data/ElectronMVAWeights/Electrons_BDT#g' -i python/electronIdMVAProducer_cfi.py
        git checkout --quiet V00-01-04 interface/ElectronEnergyRegressionEvaluate.h
        git checkout --quiet V00-01-04 src/ElectronEnergyRegressionEvaluate.cc
        git checkout --quiet V00-01-04 plugins/ElectronRegressionEnergyProducer.cc
    )

    github-addext latinos/HiggsAnalysis-CombinedLimit.git HiggsAnalysis/CombinedLimit HiggsAnalysis-CombinedLimit-V02-06-00
    github-addext latinos/UserCode-EGamma-EgammaCalibratedGsfElectrons.git EgammaCalibratedGsfElectrons Shervin13062012_2012Prompt_and_May23ReReco_and_Summer12MC_smearing_V00
    github-addext latinos/UserCode-CMG-CMGTools-External.git CMGTools/External V00-00-09
    github-addext latinos/UserCode-GCerati-DYMvaInCMSSW.git DYMvaInCMSSW V00-00-01
    (
        cd DYMvaInCMSSW
        git checkout --quiet master GetDYMVA/data/TMVA_0j_metshift_BDTG.weights.xml
        git checkout --quiet master GetDYMVA/data/TMVA_1j_metshift_BDTG.weights.xml
    )
    github-addext latinos/UserCode-pharris-MVAMet pharris/MVAMet V00-01
    (
        cd pharris/MVAMet
        rm src/PHMetAnalysisLinkDef.h
        rm src/GBRTree.cxx
        rm src/GBRForest.cxx
    )
    github-addext latinos/UserCode-scasasso-MuScleFit-Calibration.git MuScleFit/Calibration muscle_v4_2_0

    echo " - install PAT V08-09-56";
    github-addext latinos/DataFormats-PatCandidates.git DataFormats/PatCandidates DataFormats-PatCandidates-V06-05-06-10
    github-addext latinos/PhysicsTools-PatUtils.git PhysicsTools/PatUtils PhysicsTools-PatUtils-V03-09-28
    github-addext latinos/DataFormats-CaloRecHit.git DataFormats/CaloRecHit DataFormats-CaloRecHit-V02-05-11
    github-addext latinos/DataFormats-StdDictionaries.git DataFormats/StdDictionaries DataFormats-StdDictionaries-V00-02-14
    github-addext latinos/FWCore-GuiBrowsers.git FWCore/GuiBrowsers FWCore-GuiBrowsers-V00-00-70
    github-addext latinos/RecoMET-METProducers.git RecoMET/METProducers RecoMET-METProducers-V03-03-12-02
    github-addext latinos/RecoParticleFlow-PFProducer.git RecoParticleFlow/PFProducer RecoParticleFlow-PFProducer-V15-02-06
    
    echo " - newer version of the files that add extra functionalities"
    github-addext latinos/PhysicsTools-PatAlgos.git PhysicsTools/PatAlgos PhysicsTools-PatAlgos-V08-09-56
    (
        cd PhysicsTools/PatAlgos
        git checkout --quiet 2c6034a1f342f1286fd2a51eff9062bef79995cf plugins/PATPFParticleProducer.cc
        git checkout --quiet 2c6034a1f342f1286fd2a51eff9062bef79995cf plugins/PATPFParticleProducer.h
        git checkout --quiet 82c8dd0a16a4eac6286eda4a7297cc90ed2a4798 plugins/PATCleaner.cc
    )

    echo " - CommonTools/RecoUtils"
    github-addext latinos/CommonTools-RecoUtils.git CommonTools/RecoUtils CommonTools-RecoUtils-V00-01-01
    (
        cp WWAnalysis/Misc/Patches/CommonTools_RecoUtils_src_classes.h_patch          CommonTools/RecoUtils/src/classes.h
        cp WWAnalysis/Misc/Patches/CommonTools_RecoUtils_src_classes_def.xml_patch    CommonTools/RecoUtils/src/classes_def.xml
    )

    echo " - For official electron regression code";
    github-addext latinos/RecoEgamma-EgammaTools.git RecoEgamma/EgammaTools RecoEgamma-EgammaTools-V09-00-01
    github-addext latinos/EgammaAnalysis-ElectronTools.git EgammaAnalysis/ElectronTools V00-00-08

    echo " - Download regression weight file";
    wget --quiet -O EgammaAnalysis/ElectronTools/data/eleEnergyRegWeights_WithSubClusters_VApr15.root http://cmsdoc.cern.ch/cms/data/CMSSW/EgammaAnalysis/ElectronTools/data/eleEnergyRegWeights_WithSubClusters_VApr15.root; 

    echo " - adding stuff for ghost muon cleaning"
    github-addext latinos/MuonAnalysis-MuonAssociators.git MuonAnalysis/MuonAssociators MuonAnalysis-MuonAssociators-V02-03-00

    echo " - Stuff to run all the MEs" ;
    github-addext latinos/UserCode-Snowball-Higgs-Higgs_CS_and_Width.git Higgs/Higgs_CS_and_Width

    CURDIR=$PWD
    echo " - Need to tar some of the ME folders to ship them when running CRAB -- files stored in WWAnalysis/AnalysisStep/crab";
    cd $CMSSW_BASE/src/Higgs/Higgs_CS_and_Width;
    tar czf txtFiles.tar.gz txtFiles;
    mv txtFiles.tar.gz $CMSSW_BASE/src/WWAnalysis/AnalysisStep/crab/;
    cd $CURDIR

    echo " - for FatJet";
    github-addext latinos/ElectroWeakAnalysis-VPlusJets.git ElectroWeakAnalysis/VPlusJets 

    echo "======================================="
    echo " ... Done.                             "
    echo "Current Time:" $(date)
    echo "======================================="

elif [[ "$CMSSW_VERSION" == CMSSW_7_*_* ]]; then
    echo "======================================="
    echo "running with $CMSSW_VERSION - this is a 13 TeV setup!"
    echo "Current time:" $(date)
    echo "checking out additional repositories; this could take a while ..."
    echo "======================================="

    echo " - Basic Code"

    github-addext latinos/LatinoTrees.git LatinoTrees
    github-addext latinos/LatinoAnalysis.git LatinoAnalysis

    if [[ "$CMSSW_VERSION" == CMSSW_7_3_* ]]; then
       # jettoolbox
       #git cms-merge-topic alefisico:jetToolbox_73X
       # puppi       
       #git cms-addpkg CommonTools/PileupAlgos
       #git remote add nhan-remote https://github.com/nhanvtran/cmssw.git
       #git fetch nhan-remote puppi-bugfix-for-miniaod
       #git cherry-pick 0585bf21ae098f14f144b9a3d361178e6cc830e6
       git cms-addpkg CommonTools/PileupAlgos
       git remote add nhan-remote https://github.com/nhanvtran/cmssw.git
       git fetch nhan-remote puppi-with-alphas-73x
       git checkout -b puppi_dev 58ee8e8a01012601b59b3774e918f36e85f7f7d3
       git clone git@github.com:cms-jet/JetToolbox.git JMEAnalysis/JetToolbox
       git clone git@github.com:cms-jet/JMEValidator.git JMEAnalysis/JMEValidator
    fi

    if [[ "$CMSSW_VERSION" == CMSSW_7_4_14 ]]; then

	echo " - JetToolbox"
	git clone git@github.com:cms-jet/JetToolbox.git -b jetToolbox_74X JMEAnalysis/JetToolbox

	echo " - CutBasedElectronIdentificationRun2"
	# https://twiki.cern.ch/twiki/bin/viewauth/CMS/CutBasedElectronIdentificationRun2#Recipe_for_regular_users_for_7_4
	git cms-merge-topic ikrav:egm_id_7.4.12_v1

    elif [[ "$CMSSW_VERSION" == CMSSW_7_6_2 ]]; then

        echo " - JetToolbox"
#         git clone git@github.com:cms-jet/JetToolbox.git -b jetToolbox_74X JMEAnalysis/JetToolbox
        git clone git@github.com:cms-jet/JetToolbox.git -b master JMEAnalysis/JetToolbox

        echo " - CutBasedElectronIdentificationRun2"
        # https://twiki.cern.ch/twiki/bin/viewauth/CMS/CutBasedElectronIdentificationRun2#Recipe_for_regular_users_for_7_4
        # git cms-merge-topic ikrav:egm_id_7.4.12_v1

    elif [[ "$CMSSW_VERSION" == CMSSW_7_6_3 ]]; then
        
        echo " - JetToolbox"
        git clone git@github.com:cms-jet/JetToolbox.git JMEAnalysis/JetToolbox -b jetToolbox_763
        git remote add btv-cmssw https://github.com/cms-btv-pog/cmssw.git
        git fetch --tags btv-cmssw
        git cms-merge-topic cms-btv-pog:fixTMVAEvaluatorMemoryProblem-from-CMSSW_7_6_3
        echo " - everything is ready ... "

        
    elif [[ "$CMSSW_VERSION" == CMSSW_7_4_* ]]; then
    
	git clone git@github.com:cms-jet/JetToolbox.git -b jetToolbox_74X JMEAnalysis/JetToolbox

        # Get the Spring15 MC and 25ns/50ns data cut-based electron ID
        # https://twiki.cern.ch/twiki/bin/viewauth/CMS/CutBasedElectronIdentificationRun2#Recipe_for_regular_users_for_747
	git cms-merge-topic ikrav:egm_id_747_v2

        # (TEMPORARY) Include MET without HF
        # https://twiki.cern.ch/twiki/bin/view/CMS/MissingETUncertaintyPrescription#Instructions_for_7_4_X
	git cms-merge-topic -u cms-met:METCorUnc74X

        # (TEMPORARY) Puppi v8 from CMSSW_7_4_6_patch2 (included in CMSSSW from 7_4_11)
        echo " - Puppi code"

	git cms-addpkg CommonTools/PileupAlgos
	git cms-merge-topic nhanvtran:puppi-etadep-746p2-v8

       if [[ "$CMSSW_VERSION" == CMSSW_7_4_4 ]]; then
 
         # electron id
         # see https://twiki.cern.ch/twiki/bin/view/CMS/CutBasedElectronIdentificationRun2#Recipe_for_regular_users_for_74X
         git cms-merge-topic 9003 #this is the version that is in CMSSW_7_4_X
         rm -rf RecoEgamma/ElectronIdentification/data
         git clone https://github.com/cms-data/RecoEgamma-ElectronIdentification.git RecoEgamma/ElectronIdentification/data
         rm -rf RecoEgamma/PhotonIdentification/data
         git clone https://github.com/cms-data/RecoEgamma-PhotonIdentification.git RecoEgamma/PhotonIdentification/data
         ## only in cmssw releases <=744
       fi
         
    fi

    if [[ "$CMSSW_VERSION" == CMSSW_7_5_* ]]; then

       git clone git@github.com:cms-jet/JetToolbox.git -b jetToolbox_74X JMEAnalysis/JetToolbox

    fi

elif [[ "$CMSSW_VERSION" == CMSSW_8_*_* ]]; then
    echo "======================================="
    echo "running with $CMSSW_VERSION - this is a 13 TeV setup!"
    echo "Current time:" $(date)
    echo "checking out additional repositories; this could take a while ..."
    echo "======================================="

    echo " - Basic Code"

    github-addext latinos/LatinoTrees.git         LatinoTrees
    github-addext latinos/LatinoAnalysis.git      LatinoAnalysis
    github-addext latinos/PlotsConfigurations.git PlotsConfigurations

    # https://twiki.cern.ch/twiki/bin/viewauth/CMS/JetToolbox#How_to_run_the_jetToolbox
    echo " - JetToolbox"
    git clone git@github.com:cms-jet/JetToolbox.git JMEAnalysis/JetToolbox -b jetToolbox_80X_V3
    
    if [[ "$CMSSW_VERSION" == CMSSW_8_0_24_patch1 ]]; then
        echo " - EGMRegression"
        git cms-merge-topic rafaellopesdesa:Regression80XEgammaAnalysis
    fi

    if [[ "$CMSSW_VERSION" == CMSSW_8_0_2* ]]; then
        version=`echo $CMSSW_VERSION |  cut -d "_" -f 4`
        echo " - Template cross section tools "
        git cms-merge-topic -u perrozzi:HTXS_clean
      
        echo " - MET filters"
        if (( "$version" < "26" )); then
	    git cms-merge-topic -u cms-met:CMSSW_8_0_X-METFilterUpdate
#        else
#            extra MET filters not used for now
#            git cms-merge-topic -u cms-met:fromCMSSW_8_0_20_postICHEPfilter
        fi

        # EGMRegression negative energy fix
        git cms-merge-topic rafaellopesdesa:RegressionCheckNegEnergy

        echo " - MET corrections"
        git cms-merge-topic cms-met:METRecipe_8020 -u

	echo " - Electron MVA ID"
        git cms-merge-topic ikrav:egm_id_80X_v3_photons
        if (( "$version" < "26" )); then
          git cms-merge-topic ikrav:egm_id_80X_v2
          scram b -j 10
          cd $CMSSW_BASE/external/*
          git clone https://github.com/ikrav/RecoEgamma-ElectronIdentification.git data/RecoEgamma/ElectronIdentification/data
          cd data/RecoEgamma/ElectronIdentification/data
          git checkout egm_id_80X_v1
          cd $CMSSW_BASE/external/*
          git clone https://github.com/ikrav/RecoEgamma-PhotonIdentification.git data/RecoEgamma/PhotonIdentification/data
          cd data/RecoEgamma/PhotonIdentification/data
          git checkout egm_id_80X_v1
          cd $CMSSW_BASE/src
        fi

	echo " - DeepCSV " 
	git cms-merge-topic -u mverzett:DeepFlavour-from-CMSSW_8_0_21
	mkdir RecoBTag/DeepFlavour/data/
	cd RecoBTag/DeepFlavour/data/
	wget http://home.fnal.gov/~verzetti//DeepFlavour/training/DeepFlavourNoSL.json
	cd $CMSSW_BASE/src
        
        # Temporary fix for EGMRegression with VID ID combination
        if (( "$version" >= "26" )); then
            git cms-addpkg RecoEgamma/ElectronIdentification            
        fi
        sed -i 's/processName=cms.InputTag.skipCurrentProcess()/""/' RecoEgamma/ElectronIdentification/python/ElectronMVAValueMapProducer_cfi.py
    fi

    echo " - Plotting Tools"

    git clone git@github.com:yiiyama/multidraw.git LatinoAnalysis/MultiDraw
    cd LatinoAnalysis/MultiDraw
    git checkout 2.0.9 2>/dev/null
    ./mkLinkDef.py --cmssw

elif [[ "$CMSSW_VERSION" == CMSSW_9_*_* ]]; then
    echo "======================================="
    echo "running with $CMSSW_VERSION - this is a 13 TeV setup!"
    echo "Current time:" $(date)
    echo "checking out additional repositories; this could take a while ..."
    echo "======================================="

    echo " - Basic Code"

    github-addext latinos/LatinoTrees.git         LatinoTrees
    github-addext latinos/LatinoAnalysis.git      LatinoAnalysis
    github-addext latinos/PlotsConfigurations.git PlotsConfigurations

    # https://twiki.cern.ch/twiki/bin/viewauth/CMS/JetToolbox#How_to_run_the_jetToolbox
    echo " - JetToolbox"
    git clone git@github.com:cms-jet/JetToolbox.git JMEAnalysis/JetToolbox -b jetToolbox_91X_v1

    echo " - Plotting Tools"

    git clone git@github.com:yiiyama/multidraw.git LatinoAnalysis/MultiDraw
    cd LatinoAnalysis/MultiDraw
    git checkout 2.0.9 2>/dev/null
    ./mkLinkDef.py --cmssw

else
    echo "======================================="
    echo "You are using release $CMSSW_VERSION which is not supported by this script."
    echo "This script only supports the 8TeV analysis with CMSSW_5_3_9* and 13TeV analyses with CMSSW_(7,8,9)_X_Y."
    echo "If you intended to setup a 7TeV analysis please switch to the correct branch of the setup repository"
    echo "using 'cd $CMSSW_BASE/LatinosSetup && git checkout 7TeV"
    echo "======================================="
fi;
