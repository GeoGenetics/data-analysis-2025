import sys

input_file = sys.argv[1]

# Read the input data
with open(input_file) as f:
    data = f.read()

# Preprocess the data
preprocessed_data = data.replace("sample", "preprocessed")

# Write the preprocessed data to stdout
print(preprocessed_data)
