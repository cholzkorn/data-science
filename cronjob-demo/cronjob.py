# USAGE: Call this file once to write job to crontab
from crontab import CronTab

# Cronjob setup
cron = CronTab(user=True)
job = cron.new(command='cd ~/Documents/demo/; python3 savetime.py')
# Set time:
    # job.minute.every(minutes)
    # job.hour.every(hours)
    # job.dow.on('SUN', 'FRI')
    # job.month.during('APR', 'NOV')
job.minute.every(1)

# Check if job is valid, then write to global crontab file
if job.is_valid() == True:
    cron.write()
    print('Valid job. Check cron with crontab -e for job.')
else:
    print('Error: invalid job.')
