#!/usr/bin/env python3
# vim: sw=4 et

import os
import yaml
import subprocess
import re

# try to load "rich"
try:
    from rich import print
    from rich.console import Console
    console = Console()
    from rich.traceback import install
    install(show_locals=True)
except:
    pass


def ask_yn(prompt: str, default: bool):
    default_yn = 'Y/n' if default else 'y/N'
    result = default
    while True:
        answer = input(f'{prompt} [{default_yn}]: ').lower()
        if len(answer) == 0:
            break
        if len(answer) != 1:
            continue
        if answer == 'y':
            result = True
            break
        if answer == 'n':
            result = False
            break
    return result


def apply_patch(patch_file: str):
    print(f'apply patch: {os.path.basename(patch_file)}')
    subprocess.call(f'git apply {patch_file}.patch'.split(' '))
    pass


home_path = f'{os.getenv("HOME")}'
patch_path = f'{home_path}/patches'
config_file = f'{patch_path}/config.yml'
config = dict()

if os.path.isfile(config_file):
    config = yaml.safe_load(open(config_file))

# - scan for patches
# - lookup existing answers in current config
# - save new patch-answers to config
for element in os.scandir(patch_path):
    # ignore everything that is not a file
    if not os.path.isfile(element):
        continue

    # ignore everything that is not a patch
    if not element.name.endswith('.patch'):
        continue

    # get patch name
    patch_name = re.sub(r'\.patch', '', element.name)

    # get patch description, if available
    if os.path.isfile(f'{patch_path}/{patch_name}.txt'):
        with open(f'{patch_path}/{patch_name}.txt', 'r') as description_file:
            patch_description = description_file.read()
    else:
        patch_description = 'None'

    # - lookup existing answer for this patch in config
    # - ask if the patch should be applied
    # - save answer in config object
    if patch_name not in config:
        config[patch_name] = ask_yn(f'Name: {patch_name}\nDescrption: {patch_description}\nApply patch?', True)

    # if answer is "yes, it should be applied", apply patch
    if config[patch_name]:
        apply_patch(f'{patch_path}/{patch_name}')

# save config object to disk
if os.path.isfile(config_file):
    with open(config_file, 'w', 1024, 'utf8') as config_file:
        yaml.safe_dump(config, config_file)
else:
    with open(config_file, 'x', 1024, 'utf8') as config_file:
        yaml.safe_dump(config, config_file)

