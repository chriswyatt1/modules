process RATTLE_POLISH {
    tag "$meta.id"
    label 'process_low'

    if (params.enable_conda) {
        error "Conda environments are not set up for rattle (when this module was built). Please use docker or singularity containers."
    }
    container 'ecoflowucl/rattle:v1.0'

    input:
    tuple val(meta), path(reads)

    output:
    tuple val(meta), path("${meta.id}.transcriptome.fq"), emit: results
    path "versions.yml"                         , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def RATTLE_VERSION = "v1.0" // WARN: Version information not provided by tool on CLI. Please update this string when bumping container versions.
    """
    rattle \\
        polish \\
        $args \\
        -t $task.cpus \\
        -i $reads

    mv transcriptome.fq ${meta.id}.transcriptome.fq

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        rattle: $RATTLE_VERSION
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def RATTLE_VERSION = "v1.0" // WARN: Version information not provided by tool on CLI. Please update this string when bumping container versions.
    """
    touch ${meta.id}.transcriptome.fq

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        rattle: $RATTLE_VERSION
    END_VERSIONS
    """
}
