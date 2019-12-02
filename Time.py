import time
from datetime import datetime
# datetime object containing current date and time
now = datetime.now()
    
print("now =", now)
# dd/mm/YY H:M:S
dt_string = now.strftime("%d/%m/%Y %H:%M:%S")
print("date and time =", dt_string)	



# print(second)
# print(minute)
# print(hour)

while True:
    time.sleep(1)

    now = datetime.now()
    year = now.year
    month = now.month
    day = now.day
    hour = now.hour
    minute = now.minute
    second = now.second

    print(f"{hour}:{minute}:{second}")