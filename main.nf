nextflow.enable.dsl = 2

include { TRIMMOMATIC } from "./modules/trimmomatic/trimmomatic.nf"
include { RD_ANALYZER } from "./modules/rd_analyzer/rd_analyzer.nf"
include { SPOTYPING } from "./modules/spotyping/spotyping.nf"
include { SPADES } from "./modules/spades/spades.nf"
include { PROKKA } from "./modules/prokka/prokka.nf"
include { MTBSEQ } from "./modules/mtbseq/mtbseq.nf"
include { UNICYCLER } from "./modules/unicycler/unicycler.nf"

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



workflow mtbseq {

    samples_tsv_file_ch = Channel.of(params.sra_ids)
            .collect()
            .flatten().map { n ->  "$n" + "\t" + "$params.mtbseq_library_name" + "\n"  }
            .collectFile(name: 'samples.tsv', newLine: false, storeDir: "$params.resultsDir_mtbseq_cohort")

    mtbseq_called_results = Channel.of("$resultsDir_mtbseq_cohort/Called/*tab")
    mtbseq_called_results.view()

    mtbseq_position_table_results = Channel.of("$resultsDir_mtbseq_cohort/Position_Tables/*tab")

//    MTBSEQ_COHORT(
//            samples_tsv_file_ch,
//            mtbseq_called_results,
//            mtbseq_position_table_results,
//            gatk38_jar_ch,
//            env_user_ch,
//    )

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

