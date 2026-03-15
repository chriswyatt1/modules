//
// Perform a basic synteny analysis with two chromosome level genomes
//
include { GUNZIP as GUNZIP_QUERY } from '../../../modules/nf-core/gunzip/main'
include { GUNZIP as GUNZIP_REF   } from '../../../modules/nf-core/gunzip/main'
include { SYRI               } from '../../../modules/nf-core/syri/main'
include { MINIMAP2_ALIGN     } from '../../../modules/nf-core/minimap2/align/main'
include { PLOTSR             } from '../../../modules/nf-core/plotsr/main'


workflow SYRI_SYNTENY {

    take:
    ch_reads // channel: [ val(meta1), [ genome ] ]
    ch_ref   // channel: [ val(meta2), [ genome ] ]

    main:

    GUNZIP_QUERY ( ch_reads )

    GUNZIP_REF   ( ch_ref )

    MINIMAP2_ALIGN ( ch_reads , ch_ref , true, 'bai', [], [] )

    SYRI   ( MINIMAP2_ALIGN.out.bam , ch_reads , ch_ref , 'B' )

    // Stage both FASTAs together and generate the genomes TSV
    ch_fastas = GUNZIP_QUERY.out.gunzip
        .combine(GUNZIP_REF.out.gunzip)
        .map { meta1, fasta1, meta2, fasta2 ->
            [
                meta1,
                [ fasta1, fasta2 ],                          // both FASTAs staged into work dir
                "${fasta1.name}\t${meta1.id}\tlw:1.5\n${fasta2.name}\t${meta2.id}\tlw:1.5"
            ]
        }

    ch_fastas_input  = ch_fastas.map { meta, fastas, tsv -> [ meta, fastas ] }
        ch_genomes_tsv = GUNZIP_QUERY.out.gunzip
            .combine(GUNZIP_REF.out.gunzip)
            .map { meta1, fasta1, meta2, fasta2 ->
                def tsv = file("${workDir}/genomes_${meta1.id}.txt")
                tsv.text = "#file\tname\n${fasta2.name}\t${meta2.id}\n${fasta1.name}\t${meta1.id}\n"
                [ meta1, tsv ]
            }

    PLOTSR (
        SYRI.out.syri,
        ch_fastas_input,
        ch_genomes_tsv,
        [ [], [] ],
        [ [], [] ],
        [ [], [] ],
        [ [], [] ],
        [ [], [] ]
    )


    emit:
    png        = PLOTSR.out.png                  // channel: [ val(meta), [ png ] ]

}
