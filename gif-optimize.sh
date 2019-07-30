#!/bin/bash

DEFAULT_FPS=10
DEFAULT_SCALE=240

optimize_gif() {
    FILE_PATH="$1"

    if [ -f $FILE_PATH ]; then
        FPS="$2"
        SCALE="$3"

        if [ -z "$FPS" ]; then
            FPS="$DEFAULT_FPS"
        fi

        if [ -z "$SCALE" ]; then
            SCALE="$DEFAULT_SCALE"
        fi

        DIR=$(dirname "${FILE_PATH}")

        OUTPUT_DIR="$DIR/optimized-gifs"

        if [ ! -d $OUTPUT_DIR ]; then
            mkdir $OUTPUT_DIR
        fi

        FILE_NAME=$(basename "${FILE_PATH}")

        OUTPUT_FILE_PATH="$OUTPUT_DIR/$FILE_NAME"

        echo "Optimizing '$FILE_NAME' (SCALE:$SCALE, FPS:$FPS)..."

        ffmpeg -filter_complex "[0:v] fps=$FPS,scale=$SCALE:-1,split [a][b];[a] palettegen [p];[b][p] paletteuse" -y -loglevel panic -i $FILE_PATH $OUTPUT_FILE_PATH

        echo "Done! Optimized file is available at '$OUTPUT_FILE_PATH'"
    else
        echo "The file '$FILE_PATH' doesn't exist."
    fi
}

for i in "$@"
do
case $i in
    -f=*|--fps=*)
    USER_FPS="${i#*=}"
    shift
    ;;
    -s=*|--scale=*)
    USER_SCALE="${i#*=}"
    shift
    ;;
    -h|--help)
    echo "gif-optimize.sh [-f|--fps=<fps>] [-s|--scale=<scale>] <file-path|directory-path>"
    exit 0
    shift
    ;;
    *)
        if [ -f "$i" ] || [ -d "$i" ] ; then
            INPUT_PATH="$i"
        else 
            echo "Is directory"
        fi
    ;;
esac
done

if hash ffmpeg 2>/dev/null; then
    if [ -d "${INPUT_PATH}" ] ; then
        for FILE_PATH in $INPUT_PATH/*.gif; do
            optimize_gif $FILE_PATH $USER_FPS $USER_SCALE
        done
    else
        if [ -f "${INPUT_PATH}" ]; then
            optimize_gif $FILE_PATH $USER_FPS $USER_SCALE
        else
            echo "Invalid file/directory path. Please consider providing a valid one.";
            exit 1
        fi
    fi
else
    echo "I couldn't find ffmpeg on your system. Please consider installing to be able to run this script."
fi
