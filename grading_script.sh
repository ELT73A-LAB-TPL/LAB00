#!/bin/bash

# grading_script.sh
# This script is designed to be run by GitHub Actions to grade student submissions.
# It expects the student's submission file as the first argument.

STUDENT_SUBMISSION_FILE="$1"
ASSIGNMENT_NAME="simple_arithmetic" # Customize this to your assignment name
EXPECTED_OUTPUT_DIR="./expected_output" # Directory containing expected output files

# --- Configuration for Grading ---
TOTAL_POINTS=100
POINTS_PER_TEST=25 # Example: For 4 test cases
GRADE=0
FEEDBACK=""

# --- Functions for Grading ---

# Function to compile C/C++ code
compile_cpp() {
    echo "--- Compiling C++ Code ---"
    g++ -std=c++17 "${STUDENT_SUBMISSION_FILE}" -o student_program
    if [ $? -ne 0 ]; then
        FEEDBACK+="Compilation failed. "
        echo "Compilation failed."
        return 1
    fi
    echo "Compilation successful."
    return 0
}

# Function to run Python code
run_python() {
    echo "--- Running Python Code ---"
    python "${STUDENT_SUBMISSION_FILE}" "$@" # Pass arguments to the Python script
    return $? # Return the exit code of the python script
}

# Function to run compiled program (e.g., C++, Java, Go)
run_program() {
    echo "--- Running Program ---"
    ./student_program "$@" # Pass arguments to the compiled program
    return $?
}

# Function to compare output (exact match)
compare_output_exact() {
    local test_case_name="$1"
    local actual_output_file="$2"
    local expected_output_file="${EXPECTED_OUTPUT_DIR}/${test_case_name}_expected.txt"

    echo "--- Comparing Output for Test Case: ${test_case_name} ---"
    if [ ! -f "${expected_output_file}" ]; then
        echo "Error: Expected output file not found: ${expected_output_file}"
        FEEDBACK+="Test case '${test_case_name}' missing expected output. "
        return 1
    fi

    diff -q "${actual_output_file}" "${expected_output_file}" > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "Output matches expected."
        return 0
    else
        echo "Output mismatch."
        echo "--- Diff ---"
        diff "${actual_output_file}" "${expected_output_file}"
        echo "------------"
        return 1
    fi
}

# --- Main Grading Logic ---

echo "--- Starting Grading for ${ASSIGNMENT_NAME} ---"
echo "Submission: ${STUDENT_SUBMISSION_FILE}"

# --- Step 1: Pre-requisite checks (e.g., file existence) ---
if [ -z "$STUDENT_SUBMISSION_FILE" ]; then
    echo "Error: No submission file provided."
    FEEDBACK+="No submission file provided. "
    echo "Grade: 0/${TOTAL_POINTS}"
    echo "Feedback: ${FEEDBACK}"
    exit 1
fi

if [ ! -f "$STUDENT_SUBMISSION_FILE" ]; then
    echo "Error: Submission file '${STUDENT_SUBMISSION_FILE}' not found."
    FEEDBACK+="Submission file not found. "
    echo "Grade: 0/${TOTAL_POINTS}"
    echo "Feedback: ${FEEDBACK}"
    exit 1
fi

# --- Step 2: Determine Language and Compile/Run Strategy ---
FILENAME=$(basename -- "$STUDENT_SUBMISSION_FILE")
EXTENSION="${FILENAME##*.}"

case "$EXTENSION" in
    "cpp" | "cxx" | "c")
        compile_cpp
        if [ $? -ne 0 ]; then
            GRADE=0
        else
            # Run test cases for C++
            echo "--- Running Test Cases ---"
            # Test Case 1: Simple addition
            ./student_program 5 3 > student_output_test1.txt
            if compare_output_exact "test1" "student_output_test1.txt"; then
                GRADE=$((GRADE + POINTS_PER_TEST))
            else
                FEEDBACK+="Test Case 1 (5+3) failed. "
            fi

            # Test Case 2: Subtraction
            ./student_program 10 4 -s > student_output_test2.txt # Assuming -s for subtraction
            if compare_output_exact "test2" "student_output_test2.txt"; then
                GRADE=$((GRADE + POINTS_PER_TEST))
            else
                FEEDBACK+="Test Case 2 (10-4) failed. "
            fi

            # Add more test cases as needed...
        fi
        ;;
    "py")
        echo "--- Running Python Test Cases ---"
        # Test Case 1: Python simple addition
        python "${STUDENT_SUBMISSION_FILE}" 5 3 > student_output_test1.txt
        if compare_output_exact "test1" "student_output_test1.txt"; then
            GRADE=$((GRADE + POINTS_PER_TEST))
        else
            FEEDBACK+="Python Test Case 1 (5+3) failed. "
        fi

        # Test Case 2: Python multiplication
        python "${STUDENT_SUBMISSION_FILE}" 6 7 -m > student_output_test2.txt # Assuming -m for multiplication
        if compare_output_exact "test2" "student_output_test2.txt"; then
            GRADE=$((GRADE + POINTS_PER_TEST))
        else
            FEEDBACK+="Python Test Case 2 (6*7) failed. "
        fi
        ;;
    # Add more cases for other languages (e.g., "java", "js", "go")
    # For Java, you might compile with `javac` and run with `java`.
    *)
        echo "Unsupported file type: ${EXTENSION}"
        FEEDBACK+="Unsupported file type. "
        GRADE=0
        ;;
esac

# --- Final Grade Calculation and Output ---
echo "--- Grading Summary ---"
echo "Grade: ${GRADE}/${TOTAL_POINTS}"
echo "Feedback: ${FEEDBACK:-"All tests passed!"}" # Default feedback if nothing was added

# Cleanup generated files
rm -f student_program student_output_test*.txt
