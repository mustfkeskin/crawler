# -*- coding: utf-8 -*-
import scrapy

class SahibindenbotSpider(scrapy.Spider):
    name = 'sahibindenbot'
    
    allowed_domains = ['www.sahibinden.com/satilik']
    start_urls = ['https://www.sahibinden.com/satilik']
   
    #location of csv file
    custom_settings = {
        'FEED_URI' : 'tmp/sahibinden.csv'
    }
    
    
    def start_requests(self):
        index = 0
        add = 20
        urls = [
            'https://www.sahibinden.com/satilik?pagingOffset='
        ]
        while index >= 0:
            index += add
            yield scrapy.Request(url=urls[0] + str(index), callback=self.parse)
            
    
    def parse(self, response):            
       prices = response.css('.searchResultsPriceValue').extract()
       ilan_basligi = response.css('.classifiedTitle::text').extract()
       m2_oda = response.css('.searchResultsAttributeValue::text').extract()
       date = response.css('.searchResultsDateValue').extract()
       location = response.css('.searchResultsLocationValue').extract()
       detail = response.css('.classifiedTitle::attr(href)').extract()
           
       for item in zip(prices, ilan_basligi, m2_oda, date, location,detail):
                    
           yield response.follow(item[5], self.parse) 
           attributes = response.selector.xpath('//*[@id="classifiedDetail"]/div[1]/div[2]/div[2]/ul/li/strong').extract()
           values = response.selector.xpath('//*[@id="classifiedDetail"]/div[1]/div[2]/div[2]/ul/li/span').extract()
           
               
           scraped_info = {
               'prices' : item[0],
               'ilan_basligi' : item[1],
               'm2_oda' : item[2],
               'date' : item[3],
               'location' : item[4],
               'detail' : item[5],
               'attributes' : attributes,
               'values' : values
           }
           yield scraped_info  
           
           
           
           
       #next_page = response.css('.prevNextBut::attr(href)').extract_first()
       
       
       
       
           
          
