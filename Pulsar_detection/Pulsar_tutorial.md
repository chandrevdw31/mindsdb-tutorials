# **Pulsars**

>*Please note that this is a work in progress and will be updated soon.*

Pulsars are Neutron stars which emits a pattern of broadband radio waves that spreads across the sky that can be detectable from Earth. Scientists use these detections to measure cosmic distances and search for other planets as well as help pin point cosmic events like collisions between supermassive black holes by finding gravitational waves.

It can be quite tricky to detect real pulsars due to radio frequencies and noise. Through deep learning tools, we can build a simple classifier to predict whether a detected signal comes from pulsar star or from other sources such as noises, interferences, etc.

In this tutorial we will be exploring how MindsDB's predictive model can assist in classifying Pulsars and how this can help the astronomical world. Here is the fun part, everything from creating a database to creating and training a model wil be done with Docker and Python in Visual Studio Code, but you can follow along with any IDE.

## Pre-requisites

For this tutorial, ensure you have access to docker Docker. A `docker-compose.yml` file will be provided to get you started quickly.

To ensure you can complete all the steps, make sure you have access to the following tools:

1. A MindsDB instance. Check out the installation guide for [Docker](https://docs.mindsdb.com/deployment/docker/) or [PyPi](https://docs.mindsdb.com/deployment/pypi/). You can also use [MindsDB Cloud](https://docs.mindsdb.com/deployment/cloud/).
2. Downloaded the dataset. You can get it from [Kaggle](https://www.kaggle.com/colearninglounge/predicting-pulsar-starintermediate?select=pulsar_data_train.csv)
3. Optional: Access to ngrok. You can check the installation details at the [ngrok website](https://ngrok.com/).
4. Optional- Recommended : [Visual Studio Code](https://visualstudio.microsoft.com/downloads/)

## Docker

1. Create a new project directory named e.g. `mindsdb-tutorial`
2. Inside your project directory:
    2.1 Create a new file named `docker-compose.yml`.

Open the `docker-compose.yml` file with any text-editor, copy the following and save.

```docker

version: '3.5'

services:
  postgres:
    container_name: mindsdb_postgres
    image: postgres
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: changeme
      POSTGRES_DB: Pulsars
      PGDATA: /data/postgres
    volumes:
    # persist data storage in a docker container
       - mindsdb_postgres:/data/postgres
    ports:
      - "5433:5432"
    network_mode: bridge
    # restart: none


volumes:
    mindsdb_postgres:

```

This compose stack features both a Postgres database running on ports 5433 and 5432 respectively. We will install Python libraries and use python code in a Jupyter Notebook to create a Postgress database and load data into it in Visual Studio.
For the database to connect to MindsDB we will use a tunneling program Ngrok to allow the remote database connection without exposing your public IP.

Data will be loaded from a csv file using the import tool.
[Docker Volumes](https://docs.docker.com/storage/volumes/) are used for persistent storage of data.

To run, open a terminal in the project folder and run `docker-compose up -d` .
If you do not have the Docker images locally, it will first download them from docker hub and might take.

## Creating a database

The goal of creating a database in Visual Studio is to simplify the method used. We have two options- to create a python file with the relevant code in it or create a Jupyter Notebook. For the purpose of this exercise we are going to use Jupyter Notebook which will help execute the code.

We will use the libraries `sqlalchemy` and `pandas` to create the database and load data into tables.

To install the required Python libraries In a terminal, run

``` bash
pip3 install sqlalchemy pandas
```

*Please change the pip command if required for your system i.e. pip or python3 -m pip*

In Visual studio, create a new file with the extension '.ipynb' to create a Jupyter Notebook. Alternatively you can open a text editor and save the following code as a python file.

```python

from sqlalchemy import create_engine
import pandas as pd
# engine = create_engine('sqlite:///college.db', echo = True)
username='postgres'
password='changeme'
db='Pulsars'
tablename='Pulsars'

# database connection
engine = create_engine(
    f"postgresql+psycopg2://{username}:{password}@localhost:5433/{db}",
    isolation_level="SERIALIZABLE",
)

file_url = './pulsar_data_train.csv.zip'
df = pd.read_csv(file_url, dtype=float)

df.columns

```

Rename columns for ease of use.

```python

columns = {' Mean of the integrated profile': 'mean_integ_prf',
       ' Standard deviation of the integrated profile': 'std_dev_integ_prf',
       ' Excess kurtosis of the integrated profile': 'ex_kurtosis_integ_prf',
       ' Skewness of the integrated profile': 'sk_integ_prf', 
       ' Mean of the DM-SNR curve': 'mean_dm_snr_curve',
       ' Standard deviation of the DM-SNR curve': 'std_dev_dm_snr_curve',
       ' Excess kurtosis of the DM-SNR curve': 'ex_kurtosis_dm_snr_curve', 
       ' Skewness of the DM-SNR curve': 'sk_dm_snr_curve'}
df.rename(columns=columns, inplace=True, errors="raise")

```

Drop rows with nul values and and store data to table.

```python

df.dropna(inplace=True)

df.to_sql(tablename,con=engine, if_exists='replace', index=False)

```

If you are using a python file,open a terminal and execute `python3` to run the code. If you are using Jupytor Notebook you can run the code by selecting the play buttons next to the cell blocks. Select python3 when prompted.

## Accessing the Postgres Database

To access the postgres database, add the extension Postgres Management Tool by Chris Kolkman v1.1.19 in Visual studio.
> *A shortcut is to select Ctrl+Shift+X and search for the management tool.*

![Postgres Management Tool](./Selection_004.png)

### Connecting to the database

1. On the sidebar of visual studio, select the icon for the Postgress explorer.
2. Select the + button by the option POSTGRESQL EXPLORER:POSTGRESQL to add a database connection.
3. Add the hostname of the database.
>For this example, 127.0.0.1 was used.
4. Enter the PostgreSQL user to authenticate. 
>For this example it is postgres.
5. Enter the password of the PostgreSQL user.
6. Add the port number. 
>For this example 5433 was used.
7. Select the type of connection to use- use Secure Connection or Standard Connection. 
>For this example we used Standard Connection.
8. Add the name of the Database to connect to. 
>For this example Pulsars was used.
9. Add the connection name.

You can test the database by navigating to the Postgres Management Tool, selecting the hostname and database dropdowns , then right click on the table name  and choose between the select options to return the values.

## Connecting to MindsDB Cloud

We will now connect our database to MindsDB Cloud.

First, we will run the `ngrok` command to establish a connection. Open a terminal and run the following command.

```bash
ngrok tcp [db-port]
```

For this example the port number used is 5433.

You should see a similar output:

```console
Session Status                online
Account                       myaccount (Plan: Free)
Version                       2.3.40
Region                        United States (us)
Web Interface                 http://127.0.0.1:4040
Forwarding                    tcp://2.tcp.ngrok.io:14848 -> localhost:5433
```

The forwarded address information will be required when connecting to MindsDB's GUI. Select and copy the 'Forwarding' information, in this case it is `2.tcp.ngrok.io:14848`, and keep this information for later.

For the next steps we will log into the MindsDB cloud interface. MindsDB Cloud is perfect if you are unable to install MindsDB on your device. If you are not registered yet, feel free to follow the below guide. If you have already registered, skip the next steps to connect your database.

### MindsDB Studio Cloud Set Up

You can visit this [link](https://docs.mindsdb.com/deployment/cloud/) and follow the steps in registering a MindsDB Cloud account.

On the landing page, navigate to the left corner of the screen and select `ADD DATABASE`. Enter the required details. 

Too see an example, click [here](https://docs.mindsdb.com/connect/).

Click `Connect`, you should now see your Postgres database connection in the main screen.

You are now done with connecting MindsDB to your database!

## Create a predictor

Now we are ready to create our own predictor. We will start by using the MySQL API to connect to MindsDB and with a single SQL command create a predictor.

The predictor we will create will be trained to determine a detection for pulsars.

Using the following command, you will connect through the MySQL API to MindsDB.
> Please note that the username and password to use will be the credentials you registered your MindsDB account with.

```bash
mysql -h cloud.mindsdb.com --port 3306 -u cloudusername@mail.com -p
```

![MindsDB mysql client connection](./connecting_mysql_client.gif)

If you are successfully connected, make sure you connect to MindsDB's database.

```sql
USE mindsdb;
```

Use the following query to create a predictor that will predict the `target_class` for the specific field parameters.

```sql
CREATE PREDICTOR pulsar_predictor
FROM Pulsars (
    SELECT * FROM "Pulsars"
) PREDICT target_class;
```

After creating the predictor you should see a similar output:

```console
Query OK, 0 rows affected (12.18 sec)
```

The predictor was created successfully and has started training. To check the status of the model, use the below query.

```sql
SELECT * FROM mindsdb.predictors WHERE name='pulsar_predictor';

```

After the predictor has finished training, you will see a similar output. Note that MindsDB does model testing for you automatically, so you will immediately see if the predictor is accurate enough.

```console
+------------------+----------+--------------------+--------------+---------------+-----------------+-------+-------------------+------------------+
| name             | status   | accuracy           | predict      | update_status | mindsdb_version | error | select_data_query | training_options |
+------------------+----------+--------------------+--------------+---------------+-----------------+-------+-------------------+------------------+
| pulsar_predictor | complete | 0.9298938102556937 | target_class | up_to_date    | 2.61.0          | NULL  |                   |                  |
+------------------+----------+--------------------+--------------+---------------+-----------------+-------+-------------------+------------------+
1 row in set (0.59 sec)
```

The predictor has completed its training, indicated by the status column, and shows the accuracy of the model.
You can revisit training new predictors to increase accuracy by changing the query to better suit the dataset i.e. omitting certain columns etc.

Good job! We have successfully created and trained a predictive model ✨

## Make predictions

In this section you will learn how to make predictions using your trained model.
Now we will use the trained model to make predictions using a SQL query

Use the following query using mock data with the predictor.

```sql
SELECT target_class
FROM mindsdb.pulsar_predictor
WHERE when_data='{"mean_integ_prf": 116.90625, "std_dev_integ_prf": 48.92060492, "ex_kurtosis_integ_prf": 0.18604632100000001, "sk_integ_prf": -0.129815137,
"mean_dm_snr_curve": 3.037625418, "std_dev_dm_snr_curve": 17.73710156, "ex_kurtosis_dm_snr_curve": 8.122620787, "sk_dm_snr_curve": 78.81340454}'\G;
```

And just like that you are a low-level astronomer! We have successfully created and trained a model.

Want to try it out for yourself? Sign up for a [free MindsDB account](https://cloud.mindsdb.com/signup?utm_medium=community&utm_source=ext.%20blogs&utm_campaign=blog-crop-detection) and join our community!
Engage with MindsDB community on [Slack](https://join.slack.com/t/mindsdbcommunity/shared_invite/zt-o8mrmx3l-5ai~5H66s6wlxFfBMVI6wQ) or [Github](https://github.com/mindsdb/mindsdb/discussions) to ask questions, share and express ideas and thoughts!

For more check out other [tutorials and MindsDB documentation](https://docs.mindsdb.com/).