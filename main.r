### R Assignment 4 ###
##### Load packages #####

library(rtweet)
library(httpuv)
library(httr)
library(stringr)
library(tidyverse)


##### Define the twitter token #####
appname <- "<appname>"
key <- "<key>"
secret <- "<secret>"

twitter_token_Liam <- create_token(
  app=appname,
  consumer_key = key,
  consumer_secret = secret,
  set_renv = FALSE)

##### Defining objects for searching tweets #####
NBAfinals_rtweet <- search_tweets2("#NBAfinals OR 'NBA finals'",
                                token = twitter_token_Liam,
                                n=100,
                                include_rts = FALSE)

# NBAfinals_test <- search_fullarchive("#NBAfinals",
#                                      n=200,
#                                      # fromDate = "202010041930",
#                                      # toDate = "202010042359",
#                                      token = twitter_token_Liam,
#                                      env_name = twitter_token_Liam)

#### NBA tweets profanity #### 
ml <- function(searchVector) {
  conf_percent <- as.vector(NULL)
  prof_type <- as.vector(NULL)
  i <- 1
  
  for (tweet_text in searchVector) {
    response <- POST("https://api.monkeylearn.com/v3/classifiers/cl_KFXhoTdt/classify/",
                     add_headers(.headers = c("Authorization" = "Token <token>",
                                              "Content-Type" = "application/json")),
                     body = paste('{"data": ["', tweet_text, '"]}'),
                     encode = "raw")
    text_response <- content(response, as = 'text', encoding = "UTF-8")
    if(str_detect(text_response,"error_code")){
      prof_type[i] <- "Unknown"
      conf_percent[i] <- "N/A"
    } else{
      conf_string <- str_extract(text_response, regex("(\\d+)(?!.*\\d)"))
      conf_decim <- as.numeric(paste("0.",conf_string, sep = ""))
      conf_percent[i] = conf_decim
      prof_tag <- str_extract(text_response, regex("(?<=tag_name...)(\\w+)"))
      prof_type[i] = prof_tag
    }
    i = i + 1
  }
  df <- data.frame(prof_type, conf_percent)
  names(df) <- c('type', 'percent')
  return (df)
}

returnVal <- ml(NBAfinals_rtweet$text)
print(returnVal)

NBAconf_percent <- as.vector(NULL)
NBAprof_type <- as.vector(NULL)


NBAfinals_rtweet$ProfanityType <- NBAprof_type
NBAfinals_rtweet$ProfConfidence <- NBAconf_percent

##### Extracting tweets to CSV file #####
write_as_csv(NBAfinals_rtweet, "NBA_tweets.csv")

NBAdf <- 
  read_csv("C:/Users/stein/Desktop/MBA/BAIS 660/R Markdown tutorial/NBA_tweets.csv")

NBAprofanity <- ml(NBAdf$text)

NBAtweets <- cbind(NBAdf,NBAprofanity)
names(NBAtweets)[92] <- "profanity_type"
names(NBAtweets)[93] <- "prof_confidence"

NBA_profanity <- NBAtweets %>% # average confidence of clean tags
  filter(str_detect(profanity_type,"clean")) %>% 
  summarise(ave_conf = mean(as.numeric(prof_confidence), na.rm = TRUE))

write_as_csv(NBAprofanity, "NBAprofanity.csv")