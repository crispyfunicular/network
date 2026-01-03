## Installation
python3 -m venv venv  
source venv/bin/activate  
pip install wordcloud  

## Commande
wordcloud_cli --text ./pals/pals_cat/dumps-text-cat.txt --imagefile ./pals/pals_cat/wordcloud_dumps-text_cat.png

## Stopwords

Generated from the corpus top 30 words
```
cat ./pals/pals_cat/dumps-text-cat.txt | sort | uniq -c | sort -n | tail -n 30 | sed 's/.*[0-9]\+ \(.*\)/\1/' > wordcloud/cat/stopwords_cat.txt
```


Downloaded from Github
```
curl https://raw.githubusercontent.com/stopwords-iso/stopwords-ca/refs/heads/master/stopwords-ca.txt > wordcloud/cat/stopwords_cat_github.txt
```