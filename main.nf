nextflow.enable.dsl = 2

include { TRIMMOMATIC } from "./modules/trimmomatic/trimmomatic.nf"
include { RD_ANALYZER } from "./modules/rd_analyzer/rd_analyzer.nf"
include { SPOTYPING } from "./modules/spotyping/spotyping.nf"
include { SPADES } from "./modules/spades/spades.nf"
include { PROKKA } from "./modules/prokka/prokka.nf"
include { MTBSEQ_PER_SAMPLE } from "./modules/mtbseq/mtbseq_per_sample.nf"
include { MTBSEQ_COHORT } from "./modules/mtbseq/mtbseq_cohort.nf"
include { UNICYCLER } from "./modules/unicycler/unicycler.nf"
include { TBPROFILER_PROFILE; TBPROFILER_COLLATE } from "./modules/tbprofiler/tbprofiler.nf"

//include { RAXML } from "./modules/prokka/prokka.nf"

workflow {

    sra_ids_ch = Channel.fromSRA(params.sra_ids, cache: true, apiKey: params.ncbi_api_key)
    gatk38_jar_ch = Channel.value(params.gatk38_jar)
    env_user_ch = Channel.value("root")

    TRIMMOMATIC(sra_ids_ch) // DONE
    UNICYCLER(TRIMMOMATIC.out)

    MTBSEQ(TRIMMOMATIC.out,
            gatk38_jar_ch,
            env_user_ch) // DONE
    RD_ANALYZER(TRIMMOMATIC.out) // DONE
    SPOTYPING(TRIMMOMATIC.out) // DONE

    SPADES(TRIMMOMATIC.out)
    PROKKA(SPADES.out)

}



workflow SPADES_PROKKA_WF {

    sra_ids_ch = Channel.fromSRA(params.sra_ids, cache: true, apiKey: params.ncbi_api_key)
    gatk38_jar_ch = Channel.value(params.gatk38_jar)
    env_user_ch = Channel.value("root")

    TRIMMOMATIC(sra_ids_ch) // DONE

    SPADES(TRIMMOMATIC.out)
    PROKKA(SPADES.out)

}





workflow mtbseq {

    gatk38_jar_ch = Channel.value(params.gatk38_jar)
    env_user_ch = Channel.value("root")


    samples_tsv_file_ch = Channel.of(params.sra_ids)
            .collect()
            .flatten().map { n ->  "$n" + "\t" + "${params.mtbseq_library_name}" + "\n"  }
            .collectFile(name: 'samples.tsv', newLine: false, storeDir: "${params.outdir}/mtbseq/cohort")

    mtbseq_called_results_ch = Channel.fromPath("${params.outdir}/mtbseq/cohort/Called/*tab")

    mtbseq_position_table_results_ch = Channel.fromPath("${params.outdir}/mtbseq/cohort/Position_Tables/*tab")

    MTBSEQ_COHORT(
            samples_tsv_file_ch,
            mtbseq_called_results_ch.collect(),
            mtbseq_position_table_results_ch.collect(),
            gatk38_jar_ch,
            env_user_ch,
    )

}


workflow test {
    sra_ids_ch = Channel.fromSRA(params.sra_ids, cache: true, apiKey: params.ncbi_api_key)
    gatk38_jar_ch = Channel.value(params.gatk38_jar)
    env_user_ch = Channel.value("root")

    TRIMMOMATIC(sra_ids_ch) // DONE
//    UNICYCLER(TRIMMOMATIC.out) // DONE
    MTBSEQ(TRIMMOMATIC.out,
            gatk38_jar_ch,
            env_user_ch) // DONE
//    RD_ANALYZER(TRIMMOMATIC.out) // DONE
//    SPOTYPING(TRIMMOMATIC.out) // DONE
//    SPADES(TRIMMOMATIC.out) // DONE
//    PROKKA(SPADES.out) // DONE


// TODO
//   RAXML()


}



workflow TBPROFILER_WF {

    reads_ch = Channel.fromFilePairs("/home/cust100107_vol1/biosharpou/rita_bahia_analysis/86genomes_fastq/*_{1,2}.fastq.gz")

    TBPROFILER_PROFILE(reads_ch)
    TBPROFILER_COLLATE(TBPROFILER_PROFILE.out.collect())
}
