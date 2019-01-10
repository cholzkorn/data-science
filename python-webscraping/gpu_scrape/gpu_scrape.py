import bs4
from urllib.request import urlopen as uReq
from bs4 import BeautifulSoup as soup

# State website, we could also loop through pages
myurl = 'https://www.newegg.com/Video-Cards-Video-Devices/Category/ID-38?Tpk=graphics%20card'

# Open connection - download webpage
uClient = uReq(myurl)
# Store raw HTML to variable
page_html = uClient.read()
# Close internet connection
uClient.close()

# Use BeautifulSoup for HTML parsing
page_soup = soup(page_html, "html.parser")

# Look at a tag
page_soup.h1

# FindAll grabs each item
containers = page_soup.findAll("div", {"class": "item-container"})
len(containers) # how many items?
containers[0] # Subsetting to find wanted parts, jsbeautifier helps

# Grab what we want:
container = containers[0]
container.a.img["title"]

# Create CSV, write
filename = "products.csv"
f = open(filename, "w")

headers = "brand, product_name, shipping\n"

f.write(headers)

# Grabbing loop:
for container in containers:
    brand_container = container.findAll("a", {"class": "item-brand"})
    brand = brand_container[0].img["alt"]
    product_name = container.a.img["title"]
    shipping_container = container.findAll("li", {"class": "price-ship"})
    shipping = shipping_container[0].text.strip() # strip removes unwanted artifacts

    print("brand: " + brand)
    print("product_name: " + product_name)
    print("shipping: " + shipping)

    f.write(brand + "," + product_name.replace(",", "") + "," + shipping + "\n")

# Close CSV file
f.close()
