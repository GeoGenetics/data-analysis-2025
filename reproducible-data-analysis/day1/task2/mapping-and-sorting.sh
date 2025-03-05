#!/bin/bash
set -euo pipefail # Enable strict mode
trap 'echo "Error: ${BASH_SOURCE}:${LINENO}: ${BASH_COMMAND}" >&2' ERR
trap 'echo "Interrupted" >&2 ; exit 1' INT

# Define usage message
usage() {
    echo "Usage: $(basename "$0") -i <index> -r <reads> [-t <threads>]"
}

# Parse command-line arguments
while getopts ":i:r:t:" opt; do
    case ${opt} in
    i) index="${OPTARG}" ;;
    r) reads="${OPTARG}" ;;
    t) threads="${OPTARG}" ;;
    \?)
        echo "Invalid option: -${OPTARG}" >&2
        usage
        exit 1
        ;;
    :)
        echo "Option -${OPTARG} requires an argument" >&2
        usage
        exit 1
        ;;
    esac
done

# Check that required options were provided
if [[ -z "${index:-}" || -z "${reads:-}" ]]; then
    usage
    exit 1
fi

# Set default values
threads="${threads:-2}"

# Construct output file paths
file_name=$(basename ${reads})
bam_mapped_file="${file_name%%[ .]*}".mapped.bam
bam_file="${file_name%%[ .]*}".sorted.bam

# Run Bowtie2 to map the reads
bowtie2 --threads "${threads}" -x "${index}" -U "${reads}" \
    | samtools view -@ "${threads}" -bS -F 4 > "${bam_mapped_file}"

# Sort the resulting BAM file with Samtools
samtools sort -@ "${threads}" -o "${bam_file}" "${bam_mapped_file}"

# Clean up intermediate files
rm  -rf "${bam_mapped_file}"