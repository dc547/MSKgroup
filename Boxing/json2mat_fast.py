# -*- coding: utf-8 -*-
"""
json2mat_fast.py

Script to convert OpenPose json outputs to csv or mat formats. Assumes that only one
person is detected in each frame! If this assumtion is violated due to multiple 
people in the field of view or false postives only the first json object array
from each frame is unpacked and converted.

Example usage:
python json2mat.py --input "path/to/json files" --output "optional/input/for/saving" --type all
Use 'python json2mat.py --help' to see all argument parser options.

To do - update to handle with multi-person detection. (In a memory efficient way!)

Created on Tue Oct 15 17:50:15 2019
@author: LN
"""

import os
import pandas as pd
from pandas.io.json import json_normalize
import numpy as np
import scipy.io as sio
import argparse
import time
import orjson

def loadData(fullpath):
    
    # Get a list of all .json files in specifed directory
    files = [os.path.join(fullpath, f) for f in os.listdir(fullpath) if f.endswith('.json')]
    
    # allocate memory
    data = []
    # read each file in one at a time
    j = 0
    for i in files:
        print('[INFO] Reading JSON File {}: '.format(j), os.path.basename(i))
        j += 1
        # read in a give json file
        dataIn = orjson.loads(str(open(i)))
        
        # check if file contains any data - ie were any keypoints 
        # detected in this frame. If yes - unpack json object,
        # grab 2d pose data and append to list, else append a row of zeros
        if len(dataIn['people']) > 0:
            dataTemp = dataIn['people'][0]['pose_keypoints_2d']
            data.append(dataTemp)
        elif len(dataIn['people']) > 0:
            dataTemp = np.zeros((1, 75), dtype=int)
            data.append(dataTemp)
    
    # Convert list to df
    pose = pd.DataFrame(data)
    
    # Specify column names (X-coord, Y-coord, confidence score) for df 
    # and update index
    columnNames = ['NoseX', 'NoseY', 'NoseC',
                   'NeckX', 'NeckY', 'NeckC',
                   'RShoulderX', 'RShoulderY', 'RShoulderC',
                   'RElbowX', 'RElbowY', 'RElbowC',
                   'RWristX', 'RWristY', 'RWristC',
                   'LShoulderX', 'LShoulderY', 'LShoulderC',
                   'LElbowX', 'LElbowY', 'LElbowC',
                   'LWristX', 'LWristY', 'LWristC',
                   'MidHipX', 'MidHipY', 'MidHipC',
                   'RHipX', 'RHipY', 'RHipC',
                   'RKneeX', 'RKneeY', 'RKneeC',
                   'RAnkleX', 'RAnkleY', 'RAnkleC',
                   'LHipX', 'LHipY', 'LHipC',
                   'LKneeX', 'LKneeY', 'LKneeC',
                   'LAnkleX', 'LAnkleY', 'LAnkleC',
                   'REyeX', 'REyeY', 'REyeC',
                   'LEyeX', 'LEyeY', 'LEyeC',
                   'REarX', 'REarY', 'REarC',
                   'LEarX', 'LEarY', 'LEarC',
                   'LMTP1X', 'LMTP1Y', 'LMTP1C',
                   'LMTP5X', 'LMTP5Y', 'LMTP5C',
                   'LHeelX', 'LHeelY', 'LHeelC',
                   'RMTP1X', 'RMTP1Y', 'RMTP1C',
                   'RMTP5X', 'RMTP5Y', 'RMTP5C',
                   'RHeelX', 'RHeelY', 'RHeelC']
    pose.columns = columnNames
    pose.reset_index(drop=True, inplace=True)
    
    return pose

t = time.time()

# construct the argument parse and parse the arguments
ap = argparse.ArgumentParser()
ap.add_argument("--input", required=True,
    help="path to directory containing json files. Use " " if path contains spaces.")
ap.add_argument("--output", required=False, default="temp",
    help="path to directory for saving files. Default is input dir. Use " " if path contains spaces.")
ap.add_argument("--type", required=False, default="csv",
    help="output file type. Options: 'csv' or 'mat' or 'all'")
args = vars(ap.parse_args())

# Specify file Path
fullpath = args['input']

# load data from json file and convert to df
pose = loadData(fullpath)

# specify save dir
if args['output'] == 'temp':
    writePath = fullpath + '/poseData'
else:
    writePath = args['output']

# check 'type' arg and write output files accordingly
if args["type"] == 'csv':
    # write df to csv
    print('[INFO] Writing data to csv...')
    pose.to_csv (writePath+'.csv', index = None, header=True, encoding='utf-8') 
    print('[INFO] Saved: {}.csv'.format(writePath))
elif args["type"] == 'mat':
    # write dataframe to .mat format
    print('[INFO] Writing data to .mat...')
    sio.savemat(writePath+'.mat', {'poseData':pose.to_dict('split')})
    print('[INFO] Saved: {}.mat'.format(writePath))
elif args["type"] == 'all':
    print('[INFO] Writing data to all formats...')
    # write dataframe to .mat format
    print('[INFO] Writing data to .mat...')
    sio.savemat(writePath+'.mat', {'poseData':pose.to_dict('split')})
    print('[INFO] Saved: {}.mat'.format(writePath))
    # write df to csv
    print('[INFO] Writing data to csv...')
    pose.to_csv (writePath+'.csv', index = None, header=True, encoding='utf-8') 
    print('[INFO] Saved: {}.csv'.format(writePath))
    
print('\n[INFO] Processing Complete!')
print("[INFO] Processing time: {:.3f} sec\n\n".format(time.time() - t))

