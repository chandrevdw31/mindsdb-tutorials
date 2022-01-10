--To create a predictor.
CREATE PREDICTOR mushroom_predictor
FROM Pulsars (
    SELECT * FROM "mushrooms"
) as mushrooms_data
PREDICT class;

--Select a predictor to show status.
SELECT * FROM mindsdb.predictors WHERE name="mushroom_predictor";

--Query to make a prediction.
SELECT class
FROM mindsdb.mushroom_predictor
WHERE when_data='{"class": "p","cap-shape": "x","cap-surface": "s","cap-color": "n","bruises": "t","odor": "p","gill-attachment": "f","gill-spacing": "c","gill-size": "n","gill-color": "k","stalk-shape": "e","stalk-root": "e","stalk-surface-above-ring": "s","stalk-surface-below-ring": "s","stalk-color-above-ring": "w","stalk-color-below-ring": "w","veil-type": "p","veil-color": "w","ring-number": "o","ring-type": "p","spore-print-color": "k","population": "s","habitat": "u"}'\G
