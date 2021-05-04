#!/usr/bin/awk -f
BEGIN {
    OFS = FS = ","
}
{
    delim = ""
    for (i = 1; i <= NF; i++) {
        if ($i ~ /[0-9]+\.[0-9]+e[\-\+][0-9]+/) {
            printf "%s%.14f", delim, $i
        }
        else {
            printf "%s%s", delim, $i
        }
        delim = OFS
    }
    printf "\n"
}
