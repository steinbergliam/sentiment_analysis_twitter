# sentiment_analysis_twitter
 Tweets during NBA Finals
```
library(rtweet)
library(httpuv)
library(httr)
library(stringr)
library(tidyverse)
```
1. Used `rtweet` to query tweets during the NBA Finals
2. Created a function where the input is a data frame of tweet text and the output is the profanity score and confidence %
3. Used the monkeylearn profanity classifier API to calculate scores and confidence level
4. Extracted tweets and scores to csv file
