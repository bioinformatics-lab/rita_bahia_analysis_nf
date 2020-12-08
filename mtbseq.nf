#!/usr/bin/env nextflow
import java.nio.file.Paths

/*
#==============================================
code documentation
#==============================================
*/

// NOTE: To properly setup the gatk inside the docker image
// - Download the gatk-3.8.0 tar file from here https://console.cloud.google.com/storage/browser/gatk-software/package-archive/gatk;tab=objects?prefix=&forceOnObjectsSortingFiltering=false
// - tar -xvf GATK_TAR_FILE
// - gatk-register gatk_folder/gatk_jar


/*
#==============================================
PARAMS
#==============================================
*/


/*
#----------------------------------------------
flags
#----------------------------------------------
*/

params.mtbFull = false

/*
#----------------------------------------------
directories
#----------------------------------------------
*/

params.resultsDir = 'results/mtbseq/mtbFull'


/*
#----------------------------------------------
file patterns
#----------------------------------------------
*/

params.readsFilePattern = "./*_{R1,R2}.fastq.gz"

/*
#----------------------------------------------
misc
#----------------------------------------------
*/

params.saveMode = 'copy'

/*
#----------------------------------------------
channels
#----------------------------------------------
*/


Channel.fromFilePairs(params.readsFilePattern)
        .set { ch_in_mtbFull }


user_ch = Channel.value("root")

/*
#==============================================
PROCESS
#==============================================
*/

process mtbFull {
    publishDir params.resultsDir, mode: params.saveMode
    container 'quay.io/biocontainers/mtbseq:1.0.3--pl526_1'

//    container 'conmeehan/mtbseq:version1'

//    container 'arnoldliao95/mtbseq' 

//    validExitStatus 0,1,2
//    errorStrategy 'ignore'

cpus 4
maxForks 1


    when:
    params.mtbFull

    input:
    tuple genomeFileName, file("${genomeFileName}_somelib_R?.fastq.gz") from ch_in_mtbFull
    env USER from user_ch

    output:
    path("""${genomeFileName}""") into ch_out_multiqc

    script:

    """


    mkdir ${genomeFileName}
   
#    perl /MTBseq_source/MTBseq.pl --step TBfull --thread 8
    MTBseq --step TBfull --thread ${task.cpus}
    
    cp -a Amend ./${genomeFileName}/
    cp -a Bam ./${genomeFileName}/
    cp -a Called ./${genomeFileName}/
    cp -a Classification ./${genomeFileName}/
    cp -a GATK_Bam ./${genomeFileName}/
    cp -a Groups ./${genomeFileName}/
    cp -a Joint ./${genomeFileName}/
    cp -a Mpileup ./${genomeFileName}/
    cp -a Position_Tables ./${genomeFileName}/
    cp -a Statistics ./${genomeFileName}/
    """


}


/*
#==============================================
# extra
#==============================================
*/
