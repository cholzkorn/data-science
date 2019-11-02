# Sample file for illustrating functionality of cronjob.py/crontab
import datetime

with open('time.txt', mode='a') as file:
    file.write("\n" + str(datetime.datetime.now()))
