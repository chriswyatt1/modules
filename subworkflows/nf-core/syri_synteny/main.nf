// TODO nf-core: If in doubt look at other nf-core/subworkflows to see how we are doing things! :)
//               https://github.com/nf-core/modules/tree/master/subworkflows

include { SYRI               } from '../../../modules/nf-core/syri/main'
include { MINIMAP2_ALIGN     } from '../../../modules/nf-core/minimap2/align/main'
include { PLOTSR             } from '../../../modules/nf-core/plotsr/main'


workflow SYRI_SYNTENY {

    take:
    ch_reads // channel: [ val(meta1), [ genome ] ]
    ch_ref   // channel: [ val(meta2), [ genome ] ]

    main:

    MINIMAP2_ALIGN ( ch_reads , ch_ref , [] , [], [], [] )

    SYRI  ( MINIMAP2_ALIGN.out.bam , ch_reads , ch_ref , 'B' )

    PLOTSR ( SYRI.out.syri , ch_reads , ch_ref , [], [] , [], [], [] )

    emit:
    png        = PLOTSR.out.png                  // channel: [ val(meta), [ png ] ]

}
