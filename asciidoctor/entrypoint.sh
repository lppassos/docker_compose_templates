#!/usr/bin/env bash
set -e

doc=$1
theme=$2

# Defaults
DOC_PATH=${DOC_PATH:-/docs}
THEME_PATH=${THEME_PATH:-/themes}
OUT_PATH=${OUT_PATH:-/out}

# You can add custom default flags here
DEFAULT_ARGS="-a pdf-themesdir=/themes -a pdf-fontsdir=/themes/fonts"

echo "📄 Input docs: $DOC_PATH"
echo "🎨 Theme path: $THEME_PATH"
echo "📦 Output path: $OUT_PATH"

cd $DOC_PATH
# Run asciidoctor-pdf with whatever args are passed
exec asciidoctor -r asciidoctor-pdf -r asciidoctor-diagram \
    -r /extensions/chart.rb \
    -b pdf \
    --trace \
    -a "imagesoutdir=/work/.imggen" \
    -a compress \
    -v $doc
    -a pdf-theme=$theme \
    $DEFAULT_ARGS
