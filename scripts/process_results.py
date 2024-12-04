import re
import pandas as pd
import argparse


def process_results(src_file: str, dest_file: str) -> None:
    # Read the log file
    with open(src_file, 'r') as f:
        lines = f.readlines()

    # Extract CSV-like data from log lines
    pattern = r'msg="([^"]+)"'
    data = [re.search(pattern, line).group(1) for line in lines if 'msg=' in line]

    # Split the CSV-like data into columns
    columns = ['timestamp', 'url', 'method', 'status', 'response_time', 'body_size']
    rows = [row.split(',') for row in data]

    # Create a DataFrame and save it as a CSV
    df = pd.DataFrame(rows, columns=columns)
    df.to_csv(dest_file, index=False)


def parse_args():
    parser = argparse.ArgumentParser(description='Process log file and save as CSV')
    parser.add_argument('--exp-dir', type=str, help='Path to the log file')
    return parser.parse_args()


def main():
    args = parse_args()
    process_results(f'{args.exp_dir}/metrics/loadgen/out.txt', f'{args.exp_dir}/metrics/loadgen/req_results.csv') 

if __name__ == '__main__':
    main()
