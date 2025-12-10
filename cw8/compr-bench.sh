#!/bin/bash

# Sprawdzamy czy podano argumenty
if [ $# -eq 0 ]; then
    echo "Użycie: $0 <katalog1> [katalog2] ..."
    exit 1
fi

PROGRAMS="gzip bzip2 xz zstd lz4 7z"

for DIR in "$@"; do
    echo "$DIR"
    
    #tymczasowy, -d directory
    TMP_DIR=$(mktemp -d)
    TAR_FILE="$TMP_DIR/archive.tar"
    
    
    tar cf "$TAR_FILE" -C "$DIR" . > /dev/null 2>&1
    
    ORIG_SIZE=$(stat -c%s "$TAR_FILE")
    
    #naglowki
    echo -e "name\tcompress\tdecompress\tratio"

    for PROG in $PROGRAMS; do
        COMPRESSED_FILE=""
        
        #liczenie czasu
        start=`date +%s.%N`
        
        if [ "$PROG" = "7z" ]; then
            7z a "$TAR_FILE.7z" "$TAR_FILE" -bd > /dev/null 2>&1
            COMPRESSED_FILE="$TAR_FILE.7z"
            
        elif [ "$PROG" = "lz4" ]; then
            lz4 -f -q "$TAR_FILE" > "$TAR_FILE.lz4" 2>/dev/null
            COMPRESSED_FILE="$TAR_FILE.lz4"
            
        else
            #gzip, bzip2, xz, zstd
            #-c (stdout)
            
            if [ "$PROG" = "gzip" ];  then EXT=".gz"; fi
            if [ "$PROG" = "bzip2" ]; then EXT=".bz2"; fi
            if [ "$PROG" = "xz" ];    then EXT=".xz"; fi
            if [ "$PROG" = "zstd" ];  then EXT=".zst"; fi
            
            $PROG -c "$TAR_FILE" > "$TAR_FILE$EXT" 2>/dev/null
            COMPRESSED_FILE="$TAR_FILE$EXT"
        fi
        
        end=`date +%s.%N`
        comp_time=$(echo "$end - $start" | bc -l)

        if [ -f "$COMPRESSED_FILE" ]; then
            comp_size=$(stat -c%s "$COMPRESSED_FILE")
            if [ "$ORIG_SIZE" -gt 0 ]; then
                ratio=$(echo "scale=1; ($comp_size / $ORIG_SIZE) * 100" | bc -l)
            else
                ratio="0.0"
            fi
        else
            ratio="error"
            comp_size=0
        fi

        start=`date +%s.%N`
        
        if [ "$PROG" = "7z" ]; then
            7z e "$COMPRESSED_FILE" -o"$TMP_DIR/out" -y -bd > /dev/null 2>&1
        elif [ "$PROG" = "lz4" ]; then
            lz4 -d -f "$COMPRESSED_FILE" > /dev/null 2>&1
        else
            
            $PROG -d -c "$COMPRESSED_FILE" > /dev/null 2>&1
        fi
        
        end=`date +%s.%N`
        decomp_time=$(echo "$end - $start" | bc -l)

        #Wypisanie wyniku
        OUT=C printf "%s\t%.6f\t%.6f\t%s%%\n" "$PROG" "$comp_time" "$decomp_time" "$ratio"

        rm -f "$COMPRESSED_FILE" 
        rm -rf "$TMP_DIR/out"
    done
    
    echo ""
    rm -rf "$TMP_DIR"
done
