#!/usr/bin/env python
import requests
import sys, os, datetime

def slack(message):
	# Incoming webhook API token, change to yours.
	token = "EXAMPLE/FORMAT/TOKEN"
    webhook_url = 'https://hooks.slack.com/services/{0}'.format(token)
    payload = {
        'username': "Docker container",
        'text': message
    }

    response = requests.post(webhook_url, json=payload)
    if response.status_code != 200:
        raise ValueError(
            'Request to slack returned an error %s, the response is:\n%s'
            % (response.status_code, response.text)
        )

def _create_benchmarkfile():
    file = "/tmp/benchmark"
    with open(file, 'a'):
        os.utime(file, None)

def _get_start_benchmark():
    t = os.path.getmtime("/tmp/benchmark")
    return datetime.datetime.fromtimestamp(t)

def get_benchmark_time():
    current_time = datetime.datetime.now()
    spin_up = _get_start_benchmark()
    total_time = current_time - spin_up
    return total_time.seconds

def humanize_time(amount, units = 'seconds'):

    def process_time(amount, units):

        INTERVALS = [   1, 60,
                        60*60,
                        60*60*24,
                        60*60*24*7,
                        60*60*24*7*4,
                        60*60*24*7*4*12,
                        60*60*24*7*4*12*100,
                        60*60*24*7*4*12*100*10]
        NAMES = [('second', 'seconds'),
                 ('minute', 'minutes'),
                 ('hour', 'hours'),
                 ('day', 'days'),
                 ('week', 'weeks'),
                 ('month', 'months'),
                 ('year', 'years'),
                 ('century', 'centuries'),
                 ('millennium', 'millennia')]

        result = []
        unit = map(lambda a: a[1], NAMES).index(units)
        # Convert to seconds
        amount = amount * INTERVALS[unit]

        for i in range(len(NAMES)-1, -1, -1):
            a = amount // INTERVALS[i]
            if a > 0:
                result.append( (a, NAMES[i][1 % a]) )
                amount -= a * INTERVALS[i]

        return result

    rd = process_time(int(amount), units)
    cont = 0
    for u in rd:
        if u[0] > 0:
            cont += 1

    buf = ''
    i = 0
    for u in rd:
        if u[0] > 0:
            buf += "%d %s" % (u[0], u[1])
            cont -= 1

        if i < (len(rd)-1):
            if cont > 1:
                buf += ", "
            else:
                buf += " and "

        i += 1

    return buf

def main():
    type = sys.argv[1]
    if type:
        if type == "prestart":
            _create_benchmarkfile()
            message = "Docker container started."
        elif type == "poststart":
            message = "Docker container is now running.\nBenchmark measurements: {0} to completely boot.".format(humanize_time(get_benchmark_time()))
        elif type == "poststop":
            message = "Docker container gracefully stopped."
        slack(message)
    sys.exit("No valid arguments were given.")

if __name__ == '__main__':
    main()
