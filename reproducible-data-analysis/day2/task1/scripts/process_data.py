import sys

input_file = sys.argv[1]
parameter1 = int(sys.argv[2])
parameter2 = sys.argv[3]

# Read the input data
with open(input_file) as f:
    data = f.read()

# Process the data
processed_data = data.upper() + str(parameter1) + parameter2

# Write the output data to stdout
print(processed_data)
