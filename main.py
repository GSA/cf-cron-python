#!/usr/bin/env python3
from datetime import datetime

def print_something_now():

    now = datetime.now()
    print(f"something logged at: {now}")

if __name__ == '__main__':
    print_something_now()