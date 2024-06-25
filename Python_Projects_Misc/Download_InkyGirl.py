#! Python3
#Download all of InkyGirl comics
#Used with permission from Debbie Ridpath Ohi at Inkygirl.com.
# This is a fun comic about writing, and this project is a simple demonstration of web-scraping

#import
import requests, os, bs4

#check if folder exists, and if not, create it
os.makedirs("InkyGirl", exist_ok=True)
#Get first page
url_base = "https://www.inkygirl.com/inkygirl-main/category/comics-for-writers?currentPage="
i = 1
next_page_exists = True

#start while loop to go until there is no "Next 20 Entries" tag (that signals you're on the last page of the archives)
    # So we need it to not update the "next_page_exists" bool until the END of the loop, so it will still get everything on the last page
while next_page_exists:
    url = url_base + str(i) #sets url to the url for the next group of comics
    page = requests.get(url)
    page.raise_for_status()
    soup = bs4.BeautifulSoup(page.text)

    #find picture of comic in html
        #each comic seems to be the img tag inside the class "full-image-block ssNonEditable"
            #I checked and all of the classes with "full-image-block" are also "full-image-block ssNonEditable"
                #All comics are inside of div tags with "class='body'", and they're they only imgs that are! (AT LEAST ON PAGE 1)
    pic_tags_list = soup.select('.body img') # selects any "img" tags inside a tag with a class of "body"
        ###UM, THERE ARE IMAGES ON THE LAST PAGE (29) THAT ARE INSIDE THE "BODY" CLASS WITHOUT BEING COMICS!!!!
            #The picture naming conventions keep changing and the later versions tending to be better require a much more complicated solution 
            #May fix in a future version, but for now it works
    if pic_tags_list == []:
        print("could not find image")

    else:
        for j in range(len(pic_tags_list)):
            pic = pic_tags_list[j].get('src')   #selects the j-th tag in the list, then accesses the "src" attribute
            pic = pic[:pic.find("?")]           #removes everything after the .jpg, which is both unnecessary for the download 
                                                # and which interferes with the "save file" step later on
            #verify correct pic-link url formatting
            if pic[0:4] == 'http':
                pic_url = pic
            else:
                pic_url = "https://www.inkygirl.com" + pic

            print(pic_url)
            try:
                #download picture of comic
                agent_name = "your bot " + str(i) + "." + str(2*j)                  # Maybe switching the agent name repeatedly will help 
                                                                                    # the server not to send the 429 error as quickly
                res = requests.get(pic_url, headers = {'User-agent': agent_name})   # Had to add the "user-agent" header to avoid getting a 
                                                                                    # "HTTP error 429 (Too Many Requests)"
                res.raise_for_status()
                #save picture
                imageFile = open(os.path.join('InkyGirl', os.path.basename(pic_url)), 'wb')
                for chunk in res.iter_content(100000):
                    imageFile.write(chunk)
                imageFile.close()
                print("Downloaded image " + str(j+1))
            except ConnectionError:                                                 # allows it to skip any bad img urls
                print("Faulty pic url")
            except:
                print("Unknown error downloading picture " + str(j+1))
        #check for next page (aka, if the tag with "next 20 slides" exists)
        if "Next 20 Entries" in page.text:
            i = i + 1                       #update i value so it will be ready for next url
            print(i)
            print("Next 20 Entries" in page.text)

        else:
            next_page_exists = False
