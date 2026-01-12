
project_path = "MomentumFinance/MomentumFinance.xcodeproj/project.pbxproj"


def validate():
    try:
        with open(project_path) as f:
            lines = f.readlines()

        stack = []

        for i, line in enumerate(lines):
            line_num = i + 1
            # Remove comments // ...
            # Be careful with strings. assuming no " // " inside strings for now (simple parser)

            clean_line = line.split("//")[0]

            # Simple state machine for strings
            in_string = False

            # We iterate chars
            chars = list(clean_line)
            j = 0
            while j < len(chars):
                c = chars[j]

                if c == '"':
                    if j > 0 and chars[j - 1] == "\\":
                        pass  # escaped quote
                    else:
                        in_string = not in_string

                if not in_string:
                    if c == "{":
                        stack.append(("}", line_num))
                    elif c == "(":
                        stack.append((")", line_num))
                    elif c == "}" or c == ")":
                        if not stack:
                            print(f"Error at line {line_num}: Unexpected closing {c}")
                            return
                        expected, start_line = stack.pop()
                        if c != expected:
                            print(
                                f"Error at line {line_num}: Expected {expected} (started at {start_line}) but found {c}"
                            )
                            return
                j += 1

        if stack:
            expected, start_line = stack[-1]
            print(f"Error at EOF: Unclosed {expected} (started at {start_line})")
        else:
            print("Structure seems valid (balanced braces/parens).")

    except Exception as e:
        print(f"Error: {e}")


validate()
