process BEDPARSE_VALIDATEFORMAT2 {
    tag "$meta.id"
    label 'process_low'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/bedparse:0.2.3--py_0':
        'biocontainers/bedparse:0.2.3--py_0' }"

    input:
    tuple val(meta), path(bed)

    output:
    tuple val(meta), path("*.out"), emit: validatedbed
    path "versions.yml"           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    bedparse validateFormat \\
        $args \\
        $bed \\
        > ${bed}.out

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        bedparse: 0.2.3
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """

    touch ${bed}.out

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        bedparse: \$(bedparse --version)
    END_VERSIONS
    """
}
