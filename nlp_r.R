#____________________________
#  Script Information----
#____________________________
##
## Script Title: NLP with R in APEC 8222
##
## Task: Code Demo for Guest Lecture Nov.28th
##
## Author: Lifeng Ren
##
## Date Last Modified: 2023-11-28
##
## Date Created: 2023-11-28
##
## Copyright (c) Lifeng Ren, 2023
## Email: ren00154@umn.edu
##


#__________________________________________
##  Demo R in VS Code: Interface----   
#__________________________________________

v <- c(10, 20, 30, 40)

new_dt <- data.frame(name=c("John", "Jane"), age=c(30, 25))
print("Hello World!")


#__________________________________________
##  Load Library----   
#__________________________________________
# Load required libraries
library(janeaustenr)
library(textdata)
library(tidytext)
library(dplyr)
library(stringr)
library(tidyr)
library(ggplot2)
library(wordcloud)
library(reshape2)
#__________________________________________
##  Sentiment Analysis----   
#__________________________________________

original_books <- austen_books() %>%
  group_by(book) %>%
  mutate(line = row_number(),
         chapter = cumsum(str_detect(text, regex("^chapter [\\divxlc]",
                                                 ignore_case = TRUE)))) %>%
  ungroup()

original_books

tidy_books <- original_books %>%
  unnest_tokens(word, text)

tidy_books

cleaned_books <- tidy_books %>%
  anti_join(get_stopwords())

cleaned_books %>%
  count(word, sort = TRUE) 

positive <- get_sentiments("bing") %>%
  filter(sentiment == "positive")

tidy_books %>%
  filter(book == "Emma") %>%
  semi_join(positive) %>%
  count(word, sort = TRUE)


bing <- get_sentiments("bing")

janeaustensentiment <- tidy_books %>%
  inner_join(bing) %>%
  count(book, index = line %/% 80, sentiment) %>%
  spread(sentiment, n, fill = 0) %>%
  mutate(sentiment = positive - negative)


ggplot(janeaustensentiment, aes(index, sentiment, fill = book)) +
  geom_bar(stat = "identity", show.legend = FALSE) +
  facet_wrap(~book, ncol = 2, scales = "free_x")

bing_word_counts <- tidy_books %>%
  inner_join(bing) %>%
  count(word, sentiment, sort = TRUE)

bing_word_counts

bing_word_counts %>%
  filter(n > 150) %>%
  mutate(n = ifelse(sentiment == "negative", -n, n)) %>%
  mutate(word = reorder(word, n)) %>%
  ggplot(aes(word, n, fill = sentiment)) +
  geom_col() +
  coord_flip() +
  labs(y = "Contribution to sentiment")



cleaned_books %>%
  count(word) %>%
  with(wordcloud(word, n, max.words = 100))



tidy_books %>%
  inner_join(bing) %>%
  count(word, sentiment, sort = TRUE) %>%
  acast(word ~ sentiment, value.var = "n", fill = 0) %>%
  comparison.cloud(colors = c("#F8766D", "#00BFC4"),
                   max.words = 100)