#!/usr/bin/env python3
import sys
import csv

class Process:
    def __init__(self, name, length, start):
        self.name = name
        self.remaining = int(length)
        self.start = int(start)

class RobinScheduler:
    def __init__(self, processes, quantum):
        self.waiting = processes
        self.ready = []
        self.quantum = quantum
        self.time = 0

    def refresh_queue(self):
        while self.waiting and self.waiting[0].start <= self.time:
            p = self.waiting.pop(0)
            print(f"T={self.time}: New process {p.name} is waiting for execution (length={p.remaining})")
            self.ready.append(p)

    def run(self):
        if not self.waiting or self.waiting[0].start > 0:
            print("T=0: No processes currently available")

        while self.waiting or self.ready:
            self.refresh_queue()

            if not self.ready:
                if self.waiting:
                    self.time = self.waiting[0].start
                    continue
                break

            p = self.ready.pop(0)
            run_time = min(self.quantum, p.remaining)

            print(f"T={self.time}: {p.name} will be running for {run_time} time units. Time left: {p.remaining - run_time}")

            for _ in range(run_time):
                self.time += 1
                self.refresh_queue()

            p.remaining -= run_time

            if p.remaining == 0:
                print(f"T={self.time}: Process {p.name} has been finished")
            else:
                self.ready.append(p)

        print(f"T={self.time}: No more processes in queues")

def main():
    if len(sys.argv) != 3:
        sys.exit(1)

    f_path = sys.argv[1]
    q_val = int(sys.argv[2])

    procs = []
    with open(f_path) as f:
        for r in csv.reader(f):
            if r: procs.append(Process(r[0], r[1], r[2]))

    RobinScheduler(procs, q_val).run()

if __name__ == "__main__":
    main()
