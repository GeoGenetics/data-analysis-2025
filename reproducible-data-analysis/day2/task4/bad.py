from codecarbon import EmissionsTracker
import pandas as pd

# Initialize CodeCarbon tracker
tracker = EmissionsTracker(project_name="Inefficient_Data_Processing")
tracker.start()

# Creating a DataFrame
df = pd.DataFrame({'numbers': range(1, 1000000)})

# Inefficient data processing using loops
sum_total = 0
for i in range(len(df)):
    sum_total += df.iloc[i]['numbers']  # Inefficient row-wise access

# Stopping the tracker
tracker.stop()