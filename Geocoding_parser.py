import csv
import re
import os
import timeit
import datetime
from datetime import timedelta
import psycopg2
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart

smtp_server = "smtp.gmail.com"
sender_email = "rise.python.automail@gmail.com"  # Enter your address
receiver_email = "chongdi0505@gmail.com"  # Enter receiver address
password = "rise654321"

output_header = ["Ticket","Date","Time","Header","County","Rating",
                 "Longitude","Latitude","St_number","St_name","Neighborhood","City","State","Zip",
                 "Excav_company","Inter1","Inter2"]

def email_notification(subject, message):
    msg = MIMEMultipart()
    msg['From'] = sender_email
    msg['To'] = receiver_email
    msg['Subject'] = subject
    # Attach the message to the MIMEMultipart object
    msg.attach(MIMEText(message, 'plain'))
    server = smtplib.SMTP('smtp.gmail.com', 587)
    server.starttls()
    server.login(sender_email, password)
    text = msg.as_string() # You now need to convert the MIMEMultipart object to a string to send
    server.sendmail(sender_email, receiver_email, text)
    server.quit()
    
def session_start_msg(tag, name, files, entries):
    start_time = datetime.datetime.now()
    processing_duration_sec = entries * 6.3
    finish_time = start_time + timedelta(seconds = processing_duration_sec)
    subject = "EC2 Geocoding Session Started"
    part_1 = """\
    Job started at %d:%d:%d %d-%d-%d
    
    EC2 Machine Tag: %s
    EC2 Machine Name: %s
    Total input entries: %d\n
    """ % (
        start_time.time().hour,
        start_time.time().minute,
        start_time.time().second,
        start_time.date().month,
        start_time.date().day,
        start_time.date().year,
        tag,
        name,
        entries)
    part_2 = "Input files:\n"
    for job in files:
        part_2 += "\t%s\n"
    part_2 = part_2 % tuple(files)
    part_3 = """\n
    Estimated processing time: %d hours %d minutes (6.3 seconds per entry)
    Anticipated finishing time: %d:%d:%d %d-%d-%d
    """ % (processing_duration_sec // 3600,
        processing_duration_sec % 3600 // 60,
        finish_time.time().hour,
        finish_time.time().minute,
        finish_time.time().second,
        finish_time.date().month,
        finish_time.date().day,
        finish_time.date().year)
    start_message = part_1 + part_2 + part_3
    return(subject, start_message)

def session_finish_msg(tag, name, files, processed_indices, ungeocoded_indices):
    stop_time = datetime.datetime.now()
    ungeocoded_rate = ungeocoded_indices / processed_indices * 100
    subject = "EC2 Geocoding Session Complete"
    part_1 = """\
    Job finished at %d:%d:%d %d-%d-%d
    
    EC2 Machine Tag: %s
    EC2 Machine Name: %s\n
    """ % (
        stop_time.time().hour,
        stop_time.time().minute,
        stop_time.time().second,
        stop_time.date().month,
        stop_time.date().day,
        stop_time.date().year,
        tag,
        name)
    part_2 = "Input files:\n"
    for job in files:
        part_2 += "\t%s\n"
    part_2 = part_2 % tuple(files)
    part_3 = """\n
    Total processed entries: %d
    Ungeocoded entries: %d
    Ungeocoded rate: %.2f%%
    """ % (processed_indices,
        ungeocoded_indices,
        ungeocoded_rate)
    stop_message = part_1 + part_2 + part_3
    return(subject, stop_message)

def geocoder(input_path, output_path, input_file):
    # preparing for geocoding
    try:
        conn = psycopg2.connect("dbname='geocoder' user='postgres' host='localhost' password='postgres'")
        print("Database connected!", end='\r')
        cur = conn.cursor()
    except:
        print("Python is not able to connect to the database!", end='\r')
    f_in = open(input_path + input_file, 'r')
    f_out = open(output_path + input_file.replace('.txt', '.csv'), 'w')
    f_bad = open(output_path + input_file.replace('emergency', 'badlines'), 'w')
    f_log = open(output_path + input_file.replace('.txt', '.log'), 'w')
    write_header = csv.writer(f_out, lineterminator='\n')
    write_header.writerow(output_header)
    lines = f_in.readlines()
    total_entry = len(lines)
    # geocoding
    i = 0 # index for all processed entries
    n = 0 # index for all ungeocoded entries
    for line in lines:
        if not re.search(r'Ticket', line):
            rec = line.split('~')
            address = (rec[6], # street number
                       rec[7].replace("'", "''"), # street name
                       rec[4]) # city name
            expression = """SELECT g.rating, ST_X(g.geomout), ST_Y(g.geomout), (addy).address, (addy).streetname, (addy).location, (addy).stateabbrev, (addy).zip FROM geocode('%s %s, %s, NJ', 1) AS g;""" % address
            cur.execute(expression)
            try:
                rows = [str(x) for x in cur.fetchall()[0]]
                f_out.write("%s,%s,%s,%s,%s," % (
                    rec[0], # ticket
                    rec[1].split(' ')[0], # date
                    rec[1].split(' ')[1], # time
                    rec[2], # header
                    rec[3]  # county
                ))
                f_out.write("%s,%s,%s,%s,%s,%s,%s,%s," % (
                    rows[0], # rating int
                    rows[1], # longitude float.13
                    rows[2], # latitude float.13
                    rows[3], # street number int
                    rows[4], # street name string
                    rows[5], # neighborhood string
                    rows[6], # state
                    rows[7]  # zip
                ))
                f_out.write("%s,%s,%s\n" % (
                    rec[5], # excav_comp
                    rec[8], # inter1
                    rec[9].strip(), # inter2
                ))
                print("Job index %d status: complete!" % i, end='\r')
                f_log.write("Job index %d status: complete!\n" % i)
            except:
                f_bad.write("%s\n" % line)
                n += 1
                print("\rJob index %d status: bad input line!(Total: %d)" % (i, n), end='\r')
                f_log.write("Job index %d status: bad input line!(Total: %d)\n" % (i, n))
            i += 1
    # finalize geocoding
    f_in.close()
    f_out.close()
    f_bad.close()
    f_log.close()
    print("Geocoding complete!", end='\r')
    print("Input/Output files closed!", end='\r')
    if conn:
        conn.close()
        print("Database disconnected!", end='\r')
    return(i, n)

def batch_processor():
    input_dir = "./"
    output_dir = "geocoding_dump"
    # detecting job assignment file
    for item in os.listdir(input_dir):
        if re.search(r'job_Chong', item):
            break
    f = open(item, 'r')
    raw = f.readlines()
    ec2_tag = raw[0].strip().split(',')[0]
    ec2_name = raw[0].strip().split(',')[1]
    ec2_entry = int(raw[0].strip().split(',')[2])
    ec2_job = [job.strip() for job in raw[1:]]
    f.close()
    if not os.path.exists(output_dir):
        os.mkdir(output_dir)
    start_sbj, start_msg = session_start_msg(ec2_tag, ec2_name, ec2_job, ec2_entry)
    email_notification(start_sbj, start_msg)
    geocoded_entry = 0
    ungeocoded_entry = 0
    for mission in ec2_job:
        geocoded, ungeocoded = geocoder(input_dir, output_dir + '/', mission)
        geocoded_entry += geocoded
        ungeocoded_entry += ungeocoded
    stop_sbj, stop_msg = session_finish_msg(ec2_tag, ec2_name, ec2_job, geocoded_entry, ungeocoded_entry)
    email_notification(stop_sbj, stop_msg)

batch_processor()