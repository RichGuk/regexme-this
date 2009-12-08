#!/usr/bin/env python
import sys
import re
try:
    import json
except ImportError:
    import simplejson as json
from optparse import OptionParser

parser = OptionParser()

parser.add_option("-t", "--type", dest="type",
                 help="Type of regular expression (match, search or replace)")
parser.add_option("-r", "--regex", dest="regex",
               help="Regular expression for match, search or replace")
parser.add_option("-x", "--replace-data", dest="replace_data",
               help="If doing replace regex the data to replace matched\
                information with")
parser.add_option("-o", "--regex-options", dest="regex_options",
               help="List of options for the regular expression")

(options, args) = parser.parse_args()
data = args[0]
options_for_regex = 0
regex_option_list = (('dotall', re.DOTALL),
                      ('ignorecase', re.IGNORECASE),
                      ('multiline', re.MULTILINE),
                      ('verbose', re.VERBOSE),
                      ('unicode', re.UNICODE))

if options.type is None:
    print json.dumps({'error': 'Missing type'})
    sys.exit()

# Get the bitflags for the options we want.
if options.regex_options is not None:
    regex_options = options.regex_options.split(',')

    for option, flag in regex_option_list:
        if option in regex_options:
            options_for_regex |= flag

# Compile the regular expression ready for use in match, search or replace.
if options.regex is not None:
    regex = re.compile(options.regex, options_for_regex)

# We need valid regex and data to do anything now.
if regex is None or data is None:
    print json.dumps({'error': 'Missing regex or data'})
    sys.exit()

if options.type == 'match':
    match = re.match(regex, data)
    if match is None:
        print json.dumps({'error': 'No match found'})
    elif len(match.groups()) is 0:
        print json.dumps({'matches': [match.group(0)]})
    else:
        print json.dumps({'matches': match.groups(),
                          'named_matches': match.groupdict()})
elif options.type == 'match_all':
    match = re.findall(regex, data)
    if match is None:
        print json.dumps({'error': 'No match found'})
    else:
        print json.dumps({'matches': match})

elif options.type == 'replace':
    print json.dumps({'replaced_data': re.sub(regex, options.replace_data, \
        data)})