import sys
import subprocess
import os

def run_testcase(testcase, open_waveform, log_file=None):
    print(f"Running test case: {testcase}")
    
    # Remove existing cpu_wave.vcd file if it exists
    vcd_file = "cpu_wave.vcd"
    if os.path.exists(vcd_file):
        os.remove(vcd_file)
        print("Removed existing cpu_wave.vcd")
    
    # Run iverilog with the specified testcase
    iverilog_cmd = [
        "iverilog", 
        f"-DTESTCASE=\"{testcase}\"", 
        "-v", 
        "-DDEBUG", 
        "-o", "cpu_sim", 
        "-f", "filelist_tb.f"
    ]
    print("Running iverilog:", " ".join(iverilog_cmd))
    result = subprocess.run(iverilog_cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
    
    if result.returncode != 0:
        status = "FAIL"
        print(f"Error: iverilog failed for {testcase}.")
    else:
        # Run vvp simulation
        vvp_cmd = ["vvp", "cpu_sim"]
        print("Running vvp:", " ".join(vvp_cmd))
        result = subprocess.run(vvp_cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        
        # Check output for PASS/FAIL
        if "PASS" in result.stdout:
            status = "PASS"
        else:
            status = "FAIL"
        
        if result.returncode != 0:
            print(f"Error: vvp simulation failed for {testcase}.")
            status = "FAIL"
        
        # Launch gtkwave to visualize the waveform only if -vcd flag is present
        if open_waveform:
            gtkwave_cmd = ["gtkwave", "cpu_wave.vcd"]
            print("Launching gtkwave:", " ".join(gtkwave_cmd))
            subprocess.Popen(gtkwave_cmd)
    
    # Log result
    if log_file:
        log_file.write(f"{testcase}: {status}\n")

def main():
    if len(sys.argv) < 2:
        print(f"Usage: {sys.argv[0]} <testcase> or {sys.argv[0]} -f [-vcd]")
        sys.exit(1)
    
    open_waveform = "-vcd" in sys.argv
    testcases = []
    log_file = None
    
    if "-f" in sys.argv:
        testcase_file = "testcase.f"
        
        # Check if testcase file exists
        if not os.path.exists(testcase_file):
            print(f"Error: {testcase_file} not found.")
            sys.exit(1)
        
        # Read test cases from file
        with open(testcase_file, "r") as f:
            testcases = [line.strip() for line in f if line.strip()]
        
        if not testcases:
            print("Error: No test cases found in testcase.f")
            sys.exit(1)
        
        # Open log file for writing
        log_file = open("sim_result.log", "w")
    else:
        testcases = [arg for arg in sys.argv[1:] if arg != "-vcd"]
    
    # Run each testcase
    for testcase in testcases:
        run_testcase(testcase, open_waveform, log_file)
    
    # Close log file if used
    if log_file:
        log_file.close()
    
if __name__ == "__main__":
    main()
