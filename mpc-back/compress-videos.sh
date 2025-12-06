#!/bin/bash

# Video Compression Script
# Compresses all .mov files to .mp4 with h264 codec

INPUT_FOLDER="./src/videos"
OUTPUT_FOLDER="./src/videos-compressed"

# Create output folder if it doesn't exist
mkdir -p "$OUTPUT_FOLDER"

echo "========================================"
echo "Starting video compression..."
echo "Input: $INPUT_FOLDER"
echo "Output: $OUTPUT_FOLDER"
echo "========================================"

# Counter
total=0
success=0
failed=0

# Process each .mov file
for file in "$INPUT_FOLDER"/*.mov "$INPUT_FOLDER"/*.MOV; do
  # Skip if no matches
  [ -e "$file" ] || continue
  
  total=$((total + 1))
  
  # Get filename without path and extension
  filename=$(basename "$file")
  name="${filename%.*}"
  
  output="$OUTPUT_FOLDER/${name}.mp4"
  
  echo ""
  echo "[$total] Compressing: $filename"
  
  # Get original size
  original_size=$(du -h "$file" | cut -f1)
  echo "  Original size: $original_size"
  
  # Compress with ffmpeg
  # -crf 28: quality (lower = better, 23 is default, 28 is smaller file)
  # -preset medium: speed/compression balance
  # -vcodec h264: video codec
  # -acodec aac: audio codec
  # -y: overwrite without asking
  
  if ffmpeg -i "$file" \
    -vcodec h264 \
    -acodec aac \
    -crf 28 \
    -preset medium \
    -y \
    "$output" \
    -loglevel warning -stats; then
    
    # Get compressed size
    compressed_size=$(du -h "$output" | cut -f1)
    echo "  Compressed size: $compressed_size"
    echo "  ✓ Done: $output"
    success=$((success + 1))
  else
    echo "  ✗ Failed to compress: $filename"
    failed=$((failed + 1))
  fi
done

echo ""
echo "========================================"
echo "Compression complete!"
echo "Total: $total | Success: $success | Failed: $failed"
echo "========================================"
echo ""
echo "Now update your seed script to use:"
echo "const VIDEOS_FOLDER = './src/videos-compressed';"
