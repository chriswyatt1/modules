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

    PLOTSR ( SYRI.out.syri, GUNZIP_QUERY.out.gunzip, GUNZIP_REF.out.gunzip, [[], []], [[], []], [[], []], [[], []], [[], []] )

    emit:
    png        = PLOTSR.out.png                  // channel: [ val(meta), [ png ] ]

}
