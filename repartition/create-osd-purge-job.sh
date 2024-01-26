#!/bin/bash

create_osd_purge_job() {
    # Read the YAML file
    yaml_file="templates/osd-remove.yaml"
    yaml_content=$(cat "$yaml_file")

    # Substitute <OSD-IDs> with $OSD_ID
    osd_ids="$OSD_ID"
    substituted_content="${yaml_content//<OSD-IDs>/$osd_ids}"

    # Create the "out" directory if it doesn't exist
    mkdir -p out

    # Write the substituted content to a new file
    output_file="out/osd-purge-job-osd-$OSD_ID.yaml"
    echo "$substituted_content" > "$output_file"
}
