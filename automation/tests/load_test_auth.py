import time
import concurrent.futures
import sys
import os
import statistics

# Add src directory to path
sys.path.append(os.path.join(os.path.dirname(__file__), "../src"))

from jwt_auth import get_auth_manager


def load_test(num_requests=1000, num_workers=10):
    print(
        f"Starting load test with {num_requests} requests and {num_workers} workers..."
    )
    auth = get_auth_manager()

    def perform_login():
        start = time.time()
        token = auth.login("admin", "admin")
        latency = time.time() - start
        return token is not None, latency

    start_total = time.time()

    with concurrent.futures.ThreadPoolExecutor(max_workers=num_workers) as executor:
        futures = [executor.submit(perform_login) for _ in range(num_requests)]
        results = [f.result() for f in concurrent.futures.as_completed(futures)]

    total_time = time.time() - start_total

    successes = sum(1 for success, _ in results if success)
    latencies = [lat for _, lat in results]

    print("\nResults:")
    print(f"Total Time: {total_time:.2f}s")
    print(f"Throughput: {num_requests/total_time:.2f} requests/sec")
    print(f"Success rate: {successes/num_requests*100:.2f}%")

    if latencies:
        latencies_ms = [l * 1000 for l in latencies]
        print(f"Min latency: {min(latencies_ms):.2f}ms")
        print(f"Max latency: {max(latencies_ms):.2f}ms")
        print(f"Avg latency: {statistics.mean(latencies_ms):.2f}ms")
        print(f"P50 latency: {statistics.median(latencies_ms):.2f}ms")
        print(f"P99 latency: {sorted(latencies_ms)[int(len(latencies)*0.99)]:.2f}ms")


if __name__ == "__main__":
    load_test()
