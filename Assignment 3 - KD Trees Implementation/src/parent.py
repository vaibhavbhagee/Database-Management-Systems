from subprocess import Popen, PIPE
import os, signal, platform, time, sys
is_windows = (platform.system() == 'Windows')
sys.path.insert(0, 'utils')
from nbstreamreader import NonBlockingStreamReader as NBSR
from queue import Empty
from shutil import copyfile

SAFETY_TIMEOUT = 60 # Wait for at most 60 seconds for the child to answer the query | Change this as you need

# --------------------------------------------------------------------#

def exit(msg):
	print(msg)
	if (not is_windows):
		os.killpg(os.getpgid(childProc.pid), signal.SIGTERM) # kill child
	sys.exit(0) # kill self

def sigint_handler(signal, frame):
    exit('You pressed Ctrl+C!')

signal.signal(signal.SIGINT, sigint_handler)

# --------------------------------------------------------------------#

def send_data(data):
	childProc.stdin.write(data.encode())

def wait_for_data(expected_data):
	try:
		data = childStdout.readline(SAFETY_TIMEOUT).decode().strip()
		if data != expected_data:
			exit("Unexpected data received. Expected: %s. Received: %s.\nExiting."%(expected_data,data))
	except Empty as e:
		exit("No response received within %d seconds. "%SAFETY_TIMEOUT+
			"You can change this by setting SAFETY_TIMEOUT in parent.py.\nExiting.")

# --------------------------------------------------------------------#
	
if __name__ == "__main__":

	argc = len(sys.argv)
	if (argc != 4):
		print("Expected 4 arguments. Received %d. Exiting."%(argc))
		print("USAGE: python parent.py [dataset] [query] [k]")
		sys.exit(0)

	dataset_file = sys.argv[1]
	query_file = sys.argv[2]
	k = int(sys.argv[3])

	if not os.path.isfile(dataset_file):
		print('Given dataset file does not exist. Exiting.')
		print("USAGE: python parent.py [dataset] [query] [k]")
		sys.exit(0)

	if not os.path.isfile(query_file):
		print('Given query file does not exist. Exiting.')
		print("USAGE: python parent.py [dataset] [query] [k]")
		sys.exit(0)

	global childProc, childStdout
	if not is_windows:
		childProc = Popen(['sh', 'run.sh', dataset_file], 
			stdin = PIPE, stdout = PIPE, bufsize=0, preexec_fn=os.setsid)
	else:
		# Replace bash_path depending on your directory structure
		bash_path = 'C:\\Program Files\\Git\\bin\\bash.exe'
		childProc = Popen([bash_path, 'run.sh', dataset_file], 
			stdin = PIPE, stdout = PIPE, bufsize=0)

	childStdout = NBSR(childProc.stdout)

	wait_for_data('0') # Wait for child to complete kdTree construction
	send_data(query_file+'\n') # Send the name/path of query_file to the child
	start_time = time.time()
	send_data(str(k)+'\n') # Send the value of k to the child
	wait_for_data('1') # Wait for child to answer the query
	time_taken = time.time() - start_time
	
	exit("[PARENT:] Time taken to answer query: %f seconds"%time_taken)