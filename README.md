# EEGLAB on NSG and nsgportal
An Open EEGLAB Portal to High-Performance Computing: As of late 2018, EEGLAB scripts may now be run on high-performance computing resources via the freely available Neuroscience Gateway Portal to the NSF-sponsored [Comet supercomputer](https://ucsdnews.ucsd.edu/pressrelease/sdsc_to_double_comet_supercomputers_graphic_processor_count/) of the [San Diego Supercomputer Center](https://sdsc.edu/). The home page of the Neuroscience Gateway is shown below. NSG accounts are free and are not limited to US users, but the portal may only be used for non-commercial purposes (see the [NSG Terms of Use](http://www.nsgportal.org/policy.html)).
<center>
<img src="https://github.com/nucleuscub/pop_nsg_wiki/blob/master/docs/img/nsg_mainpage.jpg" alt="drawing" width="1000"/>
</center>

Like all (except personal!) supercomputers, Comet typically runs jobs in batch mode rather than in the interactive style of Matlab. However, Comet has all Matlab functions as well as EEGLAB functions and many plug-in extensions installed ready to be called from scripts. When a job submitted through the NSG portal is run, you will receive an email from NSG alerting you to download the results. This means that best uses of the Open EEGLAB Portal are for computationally intensive processes and/or for parallel, automated processing of large EEG studies. In the first category, we are now installing the most computationally intensive EEGLAB functions on comet: AMICA, RELICA, time/frequency analysis, SCALE-optimized individual subject head modeling via NFT, etc. We will give more information here about using these installed capabilities as they become available.

To read a most recent detailed overview of the Open EEGLAB Portal, browse a [conference paper submitted the IEEE/EMBS Neural Engineering Conference](https://sccn.ucsd.edu/~scott/pdf/Delorme_Open_EEGLAB_Portal_NER18.pdf) in San Francisco (March, 2019).

This respository contains the  code for the EEGLAB plug-in interfacing the NSG portal through the REST API: nsgportal. The core functions of the plug-in were initially drafted by Arnaud Delorme and further modified and reworked by Ramon Martinez-Cancino, Dung Troung and Scott Makeig (The EEGLAB Team) with substantials contributions from the NSG team at the SDSC.

# Versions
v1.0 - version used for Neuroimage 2020 article

v2.0 - version used for Nov. 2020 NSG online tutorial (increased robustness and command line calls)

**Explore the NSGPORTAL Wiki [here](https://github.com/sccn/nsgportal/wiki)**

