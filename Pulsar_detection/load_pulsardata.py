from sqlalchemy import create_engine
import pandas as pd
# engine = create_engine('sqlite:///college.db', echo = True)
username='postgres'
password='changeme'
db='Pulsars'

# database connection
engine = create_engine(
    f"postgresql+psycopg2://{username}:{password}@localhost:5433/{db}",
    isolation_level="SERIALIZABLE",
)

file_url = './pulsar_data_train.csv.zip'
df = pd.read_csv(file_url)

print(df.columns)
# df.set_index([''])

# print(df.T)

#df.to_sql('cumulative_deaths',con=engine, if_exists='replace', index=False)