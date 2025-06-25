#!/bin/bash

# grading_script.sh
# This script generates a random grade report for testing purposes.
# It does NOT process any student submission files.

# --- Configuration for Random Grade Generation ---
TOTAL_POINTS=100
MIN_GRADE=50  # Minimum possible grade
MAX_GRADE=100 # Maximum possible grade

# --- Main Logic: Generate Random Grade ---

echo "--- Generating Random Grade Report ---"

# Generate a random integer between MIN_GRADE and MAX_GRADE (inclusive)
# Using shuf for a more universally available random number generation on Linux/macOS
RANDOM_GRADE=$(shuf -i ${MIN_GRADE}-${MAX_GRADE} -n 1)

# Generate some random feedback
FEEDBACK_OPTIONS=(
    "Great work overall!"
    "Some minor issues, but good effort."
    "Needs improvement in certain areas."
    "Excellent submission, well done!"
    "Keep practicing, you'll get there!"
    "Looks good, but check the edge cases."
)
RANDOM_FEEDBACK_INDEX=$(( RANDOM % ${#FEEDBACK_OPTIONS[@]} ))
RANDOM_FEEDBACK="${FEEDBACK_OPTIONS[$RANDOM_FEEDBACK_INDEX]}"

# --- Output the Grade Report ---

echo "--- Grading Summary ---"
echo "Grade: ${RANDOM_GRADE}/${TOTAL_POINTS}"
echo "Feedback: ${RANDOM_FEEDBACK}"

# (Optional) Simulate some processing time
# sleep 2

# This script does not generate any additional files besides the stdout which is captured by the workflow.
# No cleanup needed as no temporary files are created.
