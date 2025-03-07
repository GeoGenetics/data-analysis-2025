from codecarbon import EmissionsTracker
import pandas as pd

# Initialize CodeCarbon tracker
tracker = EmissionsTracker(project_name="Efficient_Data_Processing")
tracker.start()

# Creating a DataFrame
df = pd.DataFrame({'numbers': range(1, 1000000)})

# Efficient vectorized computation
sum_total = df['numbers'].sum()  # Optimized operation using vectorization

# Stopping the tracker
tracker.stop()