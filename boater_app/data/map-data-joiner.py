import csv
from json import loads, dumps
import argparse

parser = argparse.ArgumentParser()

parser.add_argument("qualtrics_file", 
                    help="The relative or absolute file path of the Qualtrics survey response CSV.")
parser.add_argument("geojson_file", 
                    help="The relative or absolute file path of the Qualtrics survey response CSV.")
parser.add_argument("output_file", 
                    help="The relative or absolute file path where you'd like the GeoJSON and survey response combination file.")

args = parser.parse_args()

map_geojson = None
with open(args.geojson_file, "r") as geoinfile:
    map_geojson = loads(geoinfile.read())

survey_responses = {}
headers_to_merge = []
with open(args.qualtrics_file, "r") as infile:
    reader = csv.reader(infile)

    headers = next(reader)
    headers_to_merge = [header for header in headers if header != "responseID"]

    responseIDIndex = headers.index("responseID")

    for row in reader:
        survey_responses[row[responseIDIndex]] = row

for feature in map_geojson["features"]:
    if feature["properties"]["responseID"] in survey_responses:
        for header in headers_to_merge:
            header_index = headers.index(header)
            feature["properties"][header] = survey_responses[feature["properties"]["responseID"]][header_index]
    else:
        print("Couldn't find matching survey response for responseID", feature["properties"]["responseID"])


with open(args.output_file, "w") as outfile:
    outfile.write(dumps(map_geojson))