#!/usr/bin/env python3

project_path = "MomentumFinance/MomentumFinance.xcodeproj/project.pbxproj"
target_ids = [
    "C9FBC3A09F424FB4B86AA3BD",  # Ghost BuildFile
    "A139CF9EFAAE92F66141FC20",  # Ghost FileRef
    "8C7615F8D0AF42BFA2BB60D1",  # Package.swift
    "A0CORE292F0ABCDE00000001",  # SampleData (Core)
    "BC2A68F522DC4FE49D141649",  # MissingTypes (App) - If exists
    "BB7A5BD961FC5DDE5E252E17",  # Categories (Core)
    "09D3C85A68D88363F77CBB6A",  # Accounts (Core)
    "815DB79DB4126C68EBAF51E7",  # Budgets (Core)
    "1F6029DA5C07EB1C29654A0D",  # Savings (Core)
    "748B1C8D5C924066E5A8F7D3",  # Transactions (Core)
    "5213F7FF0517428AB4286AAA",  # Complex (Core)
    "A0CORE2C2F0ABCDE00000001",  # Complex (Core 2)
    "12914A324698453891FE1ACF",  # SampleGen (Core)
    "A0CORE2A2F0ABCDE00000001",  # SampleGen (Core 2)
]


def nuke():
    try:
        with open(project_path) as f:
            lines = f.readlines()

        new_lines = []
        count = 0
        for line in lines:
            hit = False
            for tid in target_ids:
                if tid in line:
                    hit = True
                    break

            if not hit:
                new_lines.append(line)
            else:
                count += 1
                # print(f"Removing: {line.strip()}")

        with open(project_path, "w") as f:
            f.writelines(new_lines)

        print(f"Nuked {count} lines.")

    except Exception as e:
        print(f"Error: {e}")


nuke()
