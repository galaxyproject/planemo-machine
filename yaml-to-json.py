#!/usr/bin/env python

from __future__ import print_function
import yaml
import json
import os
import argparse
from collections import OrderedDict

MACROS="_macros"

## Allow YAML to deal with ordered dicts

class UnsortableList(list):
    def sort(self, *args, **kwargs):
        pass
class UnsortableOrderedDict(OrderedDict):
    def items(self, *args, **kwargs):
        return UnsortableList(OrderedDict.items(self, *args, **kwargs))
yaml.add_representer(UnsortableOrderedDict, 
                     yaml.representer.SafeRepresenter.represent_dict)

## Treat unicode / str as the same things

def represent_unicode(dumper, data):
    return dumper.represent_scalar("tag:yaml.org,2002:str", data)
def construct_unicode(loader, node):
    return unicode(loader.construct_scalar(node))
yaml.add_representer(unicode, represent_unicode)
yaml.add_constructor("tag:yaml.org,2002:str", construct_unicode)


parser = argparse.ArgumentParser(description='Convert YAML to JSON (and vice versa)')
parser.add_argument('filename', metavar='SOURCEFILE', type=str, help="the file name to be converted. If it ends with '.json' a YAML file will be created. All other file extensions are assumed to by YAML and a JSON file will be created")
parser.add_argument('--force', action="store_true", default=False, help="overwrite target file, even if it is newer than the source file")

args = parser.parse_args()

path, ext = os.path.splitext(args.filename)

if ext == ".json":
    target_filename = path + ".yaml"
else:
    target_filename = path + ".json"

if os.path.isfile(target_filename):
    source_modified_time = os.stat(args.filename).st_mtime
    target_modified_time = os.stat(target_filename).st_mtime
    if target_modified_time > source_modified_time and not args.force:
        print("target file:", target_filename, "is newer than source file:", args.filename)
        exit(1)

if ext == ".json":
    with open(args.filename, 'r') as source, open(target_filename, "w") as target:
        json_data = json.load(source, object_pairs_hook=UnsortableOrderedDict)
        # if 'macros' in json_data:
        #     del json_data['macros']
        yaml.dump(json_data, target, default_flow_style=False, encoding="utf-8", allow_unicode=True )
else:
    with open(args.filename, 'r') as source, open(target_filename, "w") as target:
        yml_data = yaml.load(source, IncludeLoader)
        if MACROS in yml_data:
            del yml_data[MACROS]
        target.write(json.dumps(yml_data, indent=2))




