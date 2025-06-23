#!/usr/bin/env python3
import sys
import getpass
from passlib.hash import sha512_crypt, sha256_crypt, md5_crypt, des_crypt
from passlib.context import CryptContext

def usage():
    print("Usage: suauth.py <username>", file=sys.stderr)
    print("Not made for general use.", file=sys.stderr)
    sys.exit(2)

def main():
    if len(sys.argv) != 2:
        usage()
    username = sys.argv[1]

    try:
        with open("/etc/shadow") as f:
            lines = f.readlines()
    except Exception as e:
        print(f"Failed to read /etc/shadow: {e}", file=sys.stderr)
        sys.exit(3)

    shadow_entry = None
    for line in lines:
        fields = line.strip().split(":")
        if fields[0] == username:
            shadow_entry = fields
            break

    if not shadow_entry:
        print("No such user.", file=sys.stderr)
        sys.exit(4)

    shadow_hash = shadow_entry[1]
    
    if shadow_hash in ("*", "!", "!!"):
        print("Account is locked or disabled.", file=sys.stderr)
        sys.exit(5)

    
    if shadow_hash == "":
        sys.exit(0)

    password = getpass.getpass("Password: ")

    
    context = CryptContext(
        schemes=["sha512_crypt", "sha256_crypt", "md5_crypt", "des_crypt"],
        deprecated="auto"
    )

    try:
        if context.verify(password, shadow_hash):
            sys.exit(0)  
        else:
            sys.exit(1)  
    except Exception as e:
        print(f"Error verifying password: {e}", file=sys.stderr)
        sys.exit(6)

if __name__ == "__main__":
    main()
