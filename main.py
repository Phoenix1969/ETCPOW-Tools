import requests
import threading
import os
import shutil
from ping3 import ping
from tqdm import tqdm

# Constants
TARGET_NODES = 50
PING_TIMEOUT = 2.0
THREADS = 3
API_URL = 'https://api.etcnodes.org/peers?all=true'
NODES_FILE = "found_nodes.txt"
BATCH_FILE = "START_GETH_FAST_NODE.bat"
CONFIG_FILE = "config.toml"

def fetch_all_nodes():
    try:
        response = requests.get(API_URL)
        response.raise_for_status()
        return [node.get('enode') for node in response.json() if 'enode' in node]
    except requests.exceptions.RequestException as e:
        print(f"Error fetching nodes: {e}")
        return []

def is_port_303(enode):
    try:
        address = enode.split('@')[1]
        port = address.split(':')[1]
        return port.startswith('303')
    except IndexError:
        return False

def process_node(enode, found_nodes, seen_nodes, lock, pbar):
    if enode and enode not in seen_nodes and is_port_303(enode):
        with lock:
            seen_nodes.add(enode)
            found_nodes.append(enode)
            with open(NODES_FILE, "a") as file:
                file.write(enode + "\n")
            pbar.update(1)

def worker(all_nodes, found_nodes, seen_nodes, lock, pbar):
    while len(found_nodes) < TARGET_NODES:
        try:
            enode = all_nodes.pop(0)
            process_node(enode, found_nodes, seen_nodes, lock, pbar)
        except IndexError:
            break

def write_files(nodes):
    with open(BATCH_FILE, "w") as batch_file, open(CONFIG_FILE, "w") as config_file:
        batch_file.write("title Ethereum Classic Node\ngeth --config config.toml --classic --syncmode \"snap\" --cache 1024 --metrics --http --http.addr \"localhost\" --http.port \"8545\" --http.corsdomain \"*\" --ws --ws.addr \"localhost\" --ws.port \"8546\" --ws.origins \"*\" --datadir \".\\gethDataDirFastNode\" --identity \"ETCMCgethNode\" --port 30303 --bootnodes ")
        config_file.write("[Node.P2P]\nStaticNodes = [\n")

        for node in nodes:
            batch_file.write(node + ",")
            config_file.write('  "' + node + '",\n')

        batch_file.write(" console\n")
        config_file.write("]\n")

def move_files_and_cleanup():
    program_files = os.environ.get('ProgramFiles(x86)', 'C:\\Program Files (x86)')
    dir_1920x1080 = os.path.join(program_files, "ETCMC ETC NODE LAUNCHER 1920x1080\\ETCMC_GUI\\ETCMC_GETH")
    dir_1024x600 = os.path.join(program_files, "ETCMC ETC NODE LAUNCHER 1024x600\\ETCMC_GUI\\ETCMC_GETH")

    if os.path.exists(dir_1920x1080):
        destination_dir = dir_1920x1080
    elif os.path.exists(dir_1024x600):
        destination_dir = dir_1024x600
    else:
        print("Neither installation directory exists.")
        return  # Exit the function if neither directory exists

    for file in [BATCH_FILE, CONFIG_FILE]:
        if os.path.exists(file):
            shutil.move(file, os.path.join(destination_dir, file))

def main():
    all_nodes = fetch_all_nodes()
    found_nodes = []
    seen_nodes = set()
    lock = threading.Lock()

    with tqdm(total=TARGET_NODES, desc="Finding nodes", unit="node") as pbar:
        threads = [threading.Thread(target=worker, args=(all_nodes, found_nodes, seen_nodes, lock, pbar)) for _ in range(THREADS)]
        for t in threads:
            t.start()
        for t in threads:
            t.join()

    print(f"Total unique nodes found with port 303: {len(found_nodes)}")
    write_files(found_nodes[:TARGET_NODES])
    move_files_and_cleanup()

    print("\033[92mREM: SUCCESS. STOP YOUR NODE, CLOSE ALL GETH WINDOWS, AND RESTART YOUR NODE. NO NEED TO REBOOT\033[0m")

if __name__ == "__main__":
    main()
