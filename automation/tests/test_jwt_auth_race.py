import os
import sys
import threading

# Add src directory to path
sys.path.append(os.path.join(os.path.dirname(__file__), "../src"))

from jwt_auth import get_auth_manager


def test_concurrent_singleton_creation():
    """Test that get_auth_manager is thread-safe"""
    managers = []
    lock = threading.Lock()

    # Reset singleton for test
    import jwt_auth

    jwt_auth._auth_manager = None

    def get_manager():
        mgr = get_auth_manager()
        with lock:
            managers.append(id(mgr))

    # Spawn 100 threads
    threads = [threading.Thread(target=get_manager) for _ in range(100)]

    # Start all at once
    for t in threads:
        t.start()

    # Wait for completion
    for t in threads:
        t.join()

    # All should have same instance
    assert len(managers) == 100
    assert (
        len(set(managers)) == 1
    ), f"Multiple instances created! Found {len(set(managers))} unique instances."


def test_concurrent_login():
    """Test concurrent login operations"""
    auth = get_auth_manager()
    results = []
    lock = threading.Lock()

    def login_user():
        token = auth.login("admin", "admin")
        with lock:
            results.append(token is not None)

    threads = [threading.Thread(target=login_user) for _ in range(50)]

    for t in threads:
        t.start()
    for t in threads:
        t.join()

    # All logins should succeed
    assert all(results), "Some logins failed"
    assert len(results) == 50


if __name__ == "__main__":
    # Manually run tests if executed directly
    try:
        test_concurrent_singleton_creation()
        print("✅ test_concurrent_singleton_creation passed")
        test_concurrent_login()
        print("✅ test_concurrent_login passed")
    except AssertionError as e:
        print(f"❌ Test failed: {e}")
        sys.exit(1)
    except Exception as e:
        print(f"❌ Error: {e}")
        sys.exit(1)
