import sys
import subprocess
import os

def run_testcase(testcase, open_waveform, log_file=None, silent=False):
    if not silent:
        print(f"Running test case: {testcase}")
    
    vcd_file = "cpu_wave.vcd"
    if os.path.exists(vcd_file):
        os.remove(vcd_file)
    
    iverilog_cmd = [
        "iverilog", 
        f"-DTESTCASE=\"{testcase}\"", 
        "-v", 
        "-DDEBUG", 
        "-o", "cpu_sim", 
        "-f", "filelist_tb.f"
    ]
    result = subprocess.run(iverilog_cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
    
    if result.returncode != 0:
        status = "FAIL"
    else:
        vvp_cmd = ["vvp", "cpu_sim"]
        result = subprocess.run(vvp_cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        
        if "PASS" in result.stdout:
            status = "PASS"
        else:
            status = "FAIL"
        
        if result.returncode != 0:
            status = "FAIL"
        
        if open_waveform:
            subprocess.Popen(["gtkwave", "cpu_wave.vcd"])
    
    if log_file:
        log_file.write(f"{testcase}: {status}\n")
    
    if not silent:
        print(f"{testcase}: {status}\n")
        for line in result.stdout.strip().split('\n'):
            print(line)
        for line in result.stderr.strip().split('\n'):
            print(line)

def main():
    if len(sys.argv) < 2:
        print(f"Usage: {sys.argv[0]} <testcase> or {sys.argv[0]} -f [-vcd]")
        sys.exit(1)
    
    open_waveform = "-vcd" in sys.argv
    testcases = []
    log_file = None
    silent_mode = False
    
    if "-f" in sys.argv:
        testcase_file = "testcase.f"
        if not os.path.exists(testcase_file):
            print(f"Error: {testcase_file} not found.")
            sys.exit(1)
        
        with open(testcase_file, "r") as f:
            testcases = [line.strip() for line in f if line.strip()]
        
        if not testcases:
            print("Error: No test cases found in testcase.f")
            sys.exit(1)
        
        log_file = open("sim_result.log", "w")
        silent_mode = True
    else:
        testcases = [arg for arg in sys.argv[1:] if arg != "-vcd"]
    
    for testcase in testcases:
        run_testcase(testcase, open_waveform, log_file, silent_mode)
    
    if log_file:
        log_file.close()
        print("Results logged in sim_result.log")
    
if __name__ == "__main__":
    main()
