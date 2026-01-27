import socket
import ssl
import datetime
import smtplib
import pandas as pd
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart

domains_url = [
"google.com",
"amazon.in",
"stackoverflow.com",
]

rows = []

def ssl_expiry_datetime(hostname):
    ssl_dateformat = r'%b %d %H:%M:%S %Y %Z'

    context = ssl.create_default_context()
    context.check_hostname = False

    conn = context.wrap_socket(
        socket.socket(socket.AF_INET),
        server_hostname=hostname,
    )
    # 5 second timeout
    conn.settimeout(5.0)

    conn.connect((hostname, 443))
    ssl_info = conn.getpeercert()
    # Python datetime object
    return datetime.datetime.strptime(ssl_info['notAfter'], ssl_dateformat)

if __name__ == "__main__":
    for value in domains_url:
        now = datetime.datetime.now()
        try:
            expire = ssl_expiry_datetime(value)
            diff = expire - now
            rows.append([value, expire.strftime("%Y-%m-%d"), diff.days])
        except Exception as e:
            print (f"{value} {e}")
if rows:
    df = pd.DataFrame(rows, columns=["Domain name", "Expiry Data", "Days Left"])
    print (df)
else:
    print ("List is empty")
html_table = df.to_html(index=False, border=1)
sender_email = "v***s@gmail.com"
receiver_email = "c***3@gmail.com"
app_password = "w***"
subject = f"SSL Expiry Report"  
body = f"""
<html>
<body>
Hello Chaitanya, <br><br>
Please find the detailed report for SSL expiry check and plan your action.
<br><br>
{html_table}
<br><br>
Best Regards,<br>
Vaibhavi
"""
message = MIMEMultipart("alternative")
message["From"] = sender_email
message["To"] = receiver_email
message["Subject"] = subject
message.attach(MIMEText(body, "html"))

try:
    server = smtplib.SMTP("smtp.gmail.com", 587)
    server.starttls() 
    server.login(sender_email, app_password)
    server.sendmail(sender_email, receiver_email, message.as_string())
    print("Email sent successfully!")
except Exception as e:
    print(f"Error: {e}")
finally:
    server.quit()